

$fn=20;

lcd_panel_w=67;
lcd_panel_d=105;
lcd_panel_h=3;
lcd_screen_w=57;
lcd_screen_d=98.5;
lcd_screen_w_padding=2.5;
lcd_conn_strip_d=50;
lcd_conn_strip_w=2;
lcd_conn_strip_right_padding=15;

module lcd_panel(label=false) {
    
    module screen_box(h) {
        displacement=.5;
        translate([-((lcd_panel_w-lcd_screen_w)/2-lcd_screen_w_padding),0,lcd_panel_h/2+h/2-displacement]) cube([lcd_screen_w, lcd_screen_d, h], center=true);
    }
    
    translate([0,0,-lcd_panel_h/2]) {
        difference() {
            cube([lcd_panel_w, lcd_panel_d, lcd_panel_h], center=true);
            *screen_box(h=1);
        }
        screen_box(h=10);    
        
        if (label) {
            %translate([0,44,lcd_panel_h/3]) rotate([0,0,-90]) text("LCD SCREEN");
        }
        
        // connection strip safety box
        translate([lcd_panel_w/2,lcd_conn_strip_d/2-lcd_panel_d/2+lcd_conn_strip_right_padding,-lcd_panel_h/2]) union() {
            rotate([90,0,0]) cylinder(h=lcd_conn_strip_d, r=lcd_panel_h, center=true);
            // add extra length for bigger cases, to assist with slices
            translate([0,0,-lcd_panel_h/2]) cube([2*lcd_panel_h, lcd_conn_strip_d,lcd_panel_h], center=true);
            translate([0,0,-lcd_panel_h]) rotate([90,0,0]) cylinder(h=lcd_conn_strip_d, r=lcd_panel_h, center=true);
        }
    }
}

//!lcd_panel();

pcb_spacer_thickness=1; // +1mm to width and depth to ease placing it in the box
pcb_w=40;
pcb_d=102;
pcb_h=8; // from legs+connectors on back side to power connector on front side
pcb_antenna_connector_h=10;
pcb_antenna_connector_dia=7; // SMA diameter
pcb_antenna_back_legs=.01; // they are leveled with other connectors on that side
antenna_w_padding=1.7;
measured_distance_between_antennas_centers=(97+84.5)/2;
echo("measured_distance_between_antennas_centers: ", measured_distance_between_antennas_centers);

measured_distance_between_buttons_screw_centers=(91.8+88.3)/2;
echo("measured_distance_between_buttons_screw_centers: ", measured_distance_between_buttons_screw_centers);

measured_distance_between_antenna_center_and_buttons_screw_center=(22.4+19)/2;
echo("measured_distance_between_antenna_center_and_buttons_screw_center: ", measured_distance_between_antenna_center_and_buttons_screw_center);

measured_distance_between_central_support_screws=(25.4-9+12.4)/2;
echo("measured_distance_between_central_support_screws: ", measured_distance_between_central_support_screws);

measured_smallest_distance_between_central_support_screw_and_pcb_edge=(9+11.4)/2;
echo("measured_smallest_distance_between_central_support_screw_and_pcb_edge: ", measured_smallest_distance_between_central_support_screw_and_pcb_edge);

// NOTE: Removed power connector and soldered wires to the pcb

module pcb() {
    module ant() {
        translate([0,0,(pcb_antenna_connector_h+pcb_h+pcb_antenna_back_legs)/2-pcb_h-pcb_antenna_back_legs])
            cylinder(h=pcb_antenna_connector_h+pcb_h+pcb_antenna_back_legs, d=pcb_antenna_connector_dia, center=true);
    }
    
    screw_dia=1.8;
    screw_h=4.5;
    screw_post_dia=4.5;
    pcb_h_to_pcb=5;
    
    module screw_post() {
        difference() {
            cylinder(h=pcb_h_to_pcb, d=screw_post_dia, center=true);
            translate([0,0,-(-screw_h/2+pcb_h_to_pcb/2+0.01)]) cylinder(h=screw_h, d=screw_dia, center=true);
        }
    }
    
    center_to_antenna_center_x_vec=-(pcb_w/2-pcb_antenna_connector_dia/2-antenna_w_padding);
    center_to_buttons_screw_center_x_vec=center_to_antenna_center_x_vec+measured_distance_between_antenna_center_and_buttons_screw_center;
    
    module screw_posts() {
        union() {
            // both buttons' support screw posts, distantiated from antenna's center
            translate([center_to_buttons_screw_center_x_vec,measured_distance_between_buttons_screw_centers/2,-pcb_h_to_pcb/2+0.01]) screw_post();
            translate([center_to_buttons_screw_center_x_vec,-measured_distance_between_buttons_screw_centers/2,-pcb_h_to_pcb/2+0.01]) screw_post();
            // center closest to pcb edge screw post:
            vec_x_to_center_closest_to_pcb_edge_screw_post=-pcb_w/2+measured_smallest_distance_between_central_support_screw_and_pcb_edge;
            translate([vec_x_to_center_closest_to_pcb_edge_screw_post,0,-pcb_h_to_pcb/2+0.01]) screw_post();
            // last center screw post:
            translate([vec_x_to_center_closest_to_pcb_edge_screw_post+measured_distance_between_central_support_screws,0,-pcb_h_to_pcb/2+0.01]) screw_post();
        }
    }
    
    button_cut_width=0.8;
    button_d=7;
    button_w=10;
    button_cut_h=10+pcb_h_to_pcb;
    button_leg_thinning=1;
    pcb_button_h=3.8-1.4;
    button_h=pcb_h_to_pcb-pcb_button_h;
    
    module button_cuts() {
        union() {
            translate([-button_cut_width/2,button_cut_width/2+button_d/2,0]) cube([button_w+button_cut_width,button_cut_width,button_cut_h], center=true);
            translate([-button_cut_width/2,-(button_cut_width/2+button_d/2),0]) cube([button_w+button_cut_width,button_cut_width,button_cut_h], center=true);
            translate([-button_cut_width/2-button_w/2,0,0]) cube([button_cut_width,button_d+2*button_cut_width,button_cut_h], center=true);
            translate([button_w/2-(button_w-button_d)/2,0,button_leg_thinning/2-(button_cut_h/2-pcb_h_to_pcb)]) cube([button_w-button_d,button_d,button_leg_thinning], center=true);
        }
    }
    
    module button() {
        translate([-(button_w-button_d)/2,0,0]) cube([button_d,button_d,button_h], center=true);
    }
    
    one_side_buttons_distance=screw_post_dia+1; // NOTE: if zero distance, then they will share the cut
    
    button_FR_PLUS_vec=[-button_w/2-button_cut_width+button_cut_width/2-one_side_buttons_distance/2,measured_distance_between_buttons_screw_centers/2,0];
    button_CH_MIN_vec =[-button_w/2-button_cut_width+button_cut_width/2+button_w+button_cut_width+one_side_buttons_distance/2,measured_distance_between_buttons_screw_centers/2,0];
    button_MENU_vec   =[-button_w/2-button_cut_width+button_cut_width/2-one_side_buttons_distance/2,-measured_distance_between_buttons_screw_centers/2,0];
    button_AUTO_vec   =[-button_w/2-button_cut_width+button_cut_width/2+button_w+button_cut_width+one_side_buttons_distance/2,-measured_distance_between_buttons_screw_centers/2,0];
    
    module place_buttons() {
        translate([center_to_buttons_screw_center_x_vec,0,0]) {
            translate(button_FR_PLUS_vec) rotate([0,0,180]) children(0);
            translate(button_CH_MIN_vec)                    children(1);
            translate(button_MENU_vec)    rotate([0,0,180]) children(2);
            translate(button_AUTO_vec)                      children(3);
        }
    }

    module buttons_cuts() {
        translate([0,0,button_cut_h/2-pcb_h_to_pcb])
        place_buttons() {
            button_cuts();
            button_cuts();
            button_cuts();
            button_cuts();
        }
    }
    
    module buttons() {
        translate([0,0,-button_h/2+0.01])
        place_buttons() {
            button();
            button();
            button();
            button();
        }
    }
    
    difference() {
        union() {
            // pcb itself
            translate([0,0,-pcb_h/2]) cube([pcb_w,pcb_d,pcb_h], center=true);

            // safe margin to ease in case placement
            translate([0,0,-pcb_h/2]) cube([pcb_w+pcb_spacer_thickness,pcb_d+pcb_spacer_thickness,pcb_h], center=true);
            
            // antennas
            translate([center_to_antenna_center_x_vec,measured_distance_between_antennas_centers/2,0]) ant();
            translate([center_to_antenna_center_x_vec,-measured_distance_between_antennas_centers/2,0]) ant();
            buttons_cuts();
        }
        screw_posts();
        buttons();
    }
}

//!%pcb();

battery_w=35.4;
battery_d=79;
battery_h=24;

module battery_compartment() {
    union() {
        cube([battery_w,battery_d,battery_h], center=true);
        
        // NOTE: See [insert_part] slice for space for wires
        
        // Open cut for space for usb connection a charging status led
        cube([battery_w+10,battery_d-2*10,battery_h-2*3], center=true);
    }
}

on_off_sw_w=14;
on_off_sw_d=21;
on_off_sw_h=7;
on_off_sw_button_w=8.5;
on_off_sw_button_d=8;
on_off_sw_button_h=5.5;
on_off_sw_h_to_pcb=5;
on_off_sw_screw_post_dia=5;
on_off_sw_screw_post_displacement_w=-1;

module on_off_switch() {
    screw_dia=1.8;
    screw_h=4;
    screw_posts_distance=15;
    
    module screw_post() {
        difference() {
            union() {
                cylinder(h=on_off_sw_h_to_pcb, d=on_off_sw_screw_post_dia, center=true);
                translate([0,-on_off_sw_screw_post_dia/2,0]) cube([on_off_sw_screw_post_dia,on_off_sw_screw_post_dia,on_off_sw_h_to_pcb], center=true);
            }
            translate([0,0,-screw_h/2+on_off_sw_h_to_pcb/2+0.01]) cylinder(h=screw_h, d=screw_dia, center=true);
        }
    }
        
    difference() {
        union() {
            cube([on_off_sw_w,on_off_sw_d,on_off_sw_h], center=true);
        
            // button safe cut
            translate([on_off_sw_w/2 + on_off_sw_button_w/2 - 0.01,0,+on_off_sw_button_h/2-on_off_sw_h/2])
              cube([on_off_sw_button_w,on_off_sw_button_d,on_off_sw_button_h], center=true);
            
            // backside safe cut space
            translate([-on_off_sw_w/2,0,0]) cube([on_off_sw_w,on_off_sw_d,on_off_sw_h], center=true);
        }
        
        // screw posts
        #union() {
            translate([on_off_sw_screw_post_displacement_w,screw_posts_distance/2,on_off_sw_h_to_pcb/2-on_off_sw_h/2-0.01])
              rotate([0,0,180])screw_post();
            translate([on_off_sw_screw_post_displacement_w,-screw_posts_distance/2,on_off_sw_h_to_pcb/2-on_off_sw_h/2-0.01])
              rotate([0,0,0]) screw_post();
        }
    }
}

//!on_off_switch();

// TODO: add connection for fan --> to plug it when working at the bench w drone!!!???

case_w=81;
case_d=111;
case_h_depth_for_lcd=1;
case_h_depth=2;
case_lcd_inner_isolation_layer_depth=2;
battery_w_displacement=10;
case_h=
    case_h_depth_for_lcd+
    lcd_panel_h+
    case_lcd_inner_isolation_layer_depth+
    battery_h+
    case_h_depth; // NOTE: mind isolation between [pcb_antenna_back_legs] and [lcd_panel]!!!
echo("case height: ", case_h);
case_inner_slice_wall=case_h_depth+2;
top_battery_wall_h=2;


pcb_cap_h=case_h/2-case_h_depth-pcb_h+.01;

module case(label=false) {
    module case_w_pcb() {
        difference() {
            cube([case_w, case_d, case_h], center=true);            
            translate([case_w/2-pcb_w/2-case_h_depth,0,-(case_h/2-case_h_depth)]) rotate([180,0,0]) pcb();
        }
    }
    
    module case_w_pcb_and_bat() {
        difference() {
            case_w_pcb();
            translate([-case_w/2+battery_w/2+case_h_depth,0+battery_w_displacement,battery_h/2-(+case_h/2-case_h_depth)]) battery_compartment();
        }
    }
    
    module case_w_pcb_and_bat_and_power_sw() {
        difference() {
            case_w_pcb_and_bat();
            translate([-case_w/2+on_off_sw_d/2+case_h_depth,on_off_sw_w/2-(+case_d/2-case_h_depth),-on_off_sw_h/2-(+case_h/2-case_h_depth)+pcb_h]) rotate([0,0,-90]) on_off_switch();
        }
    }
    
    module case_w_pcb_and_bat_and_power_sw_and_lcd(label=false) {
        difference() {
            case_w_pcb_and_bat_and_power_sw();
            translate([((lcd_panel_w-lcd_screen_w)/2-lcd_screen_w_padding),0,case_h/2-case_h_depth_for_lcd]) lcd_panel(label);
        }
    }
         
    // NOTE: Usb hole is cut by battery-compartment
    
    // holding screws
    holding_dia=5;
    holding_on_d=0;
    holding_on_w=1;

    module holds(dia, h=case_h) {
        module holding_cyl() {
            cylinder(h=h, d=dia, center=true);
        }
        translate([case_w/2-holding_on_d*holding_dia/2,case_d/2-holding_on_w*holding_dia/2,0]) holding_cyl();
        translate([-(case_w/2-holding_on_d*holding_dia/2),case_d/2-holding_on_w*holding_dia/2,0]) holding_cyl();
        translate([case_w/2-holding_on_d*holding_dia/2,-case_d/2+holding_on_w*holding_dia/2,0]) holding_cyl();
        translate([-(case_w/2-holding_on_d*holding_dia/2),-case_d/2+holding_on_w*holding_dia/2,0]) holding_cyl();
    }

    holding_inner_dia=2;    
    difference() {
        union() {
            case_w_pcb_and_bat_and_power_sw_and_lcd(label);
            holds(dia=holding_dia);
        }
        holds(dia=holding_inner_dia, h=case_h*2);
    }
}

//!case();

module sliced_case(separate=20, place=true) {
    slice_size=300;
    
    lcd_cap_h=case_h/2-case_h_depth_for_lcd-lcd_panel_h+.01;
    module lcd_cap() {
        difference() {
            case(label=true);
            translate([0,0,-slice_size/2+lcd_cap_h]) cube(slice_size, center=true);
        }
    }
    
    module pcb_cap() {
        difference() {
            case();
            translate([0,0,slice_size/2-pcb_cap_h]) cube(slice_size, center=true);
        }
    }
    
    module insert_part() {
        insert_height=lcd_cap_h + pcb_cap_h;
        difference() {
            intersection() {
                case();
                translate([0,0,insert_height/2-pcb_cap_h-0.011]) // -0.011 back to ease printing 
                    cube([slice_size,slice_size,insert_height], center=true);
            }
            translate([0,0,-slice_size/2+lcd_cap_h-case_lcd_inner_isolation_layer_depth-top_battery_wall_h])
                cube([case_w-2*case_inner_slice_wall, case_d-2*case_inner_slice_wall, slice_size], center=true);
        }
    }
    
    translate([0,0,separate]) if (!place) lcd_cap(); else translate([case_w+separate,0,lcd_cap_h-separate]) rotate([0,180,0]) lcd_cap();

    %if (!place) insert_part(); else translate([0,0,-pcb_cap_h]) rotate([0,180,0]) insert_part();
    
    !translate([0,0,-separate]) if (!place) pcb_cap(); else translate([-case_w-separate,0,pcb_cap_h+separate]) rotate([0,0,0]) pcb_cap();
}


sliced_case(place=true);
