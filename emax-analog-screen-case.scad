

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

pcb_w=40;
pcb_d=102;
pcb_h=8; // from legs+connectors on back side to power connector on front side
pcb_antenna_connector_h=10;
pcb_antenna_connector_dia=6; // SMA diameter
pcb_antenna_back_legs=.01; // they are leveled with other connectors on that side
antenna_w_padding=3;
antenna_d_padding=3;

// NOTE: will remove power connector and solder wires to the pcb
//power_connection_w=18;
//power_connection_d=0;

module pcb() {
    // pcb itself
    translate([0,0,-pcb_h/2]) cube([pcb_w,pcb_d,pcb_h], center=true);
    
    // antennas
    module ant() {
        translate([0,0,(pcb_antenna_connector_h+pcb_h+pcb_antenna_back_legs)/2-pcb_h-pcb_antenna_back_legs])
            cylinder(h=pcb_antenna_connector_h+pcb_h+pcb_antenna_back_legs, d=pcb_antenna_connector_dia, center=true);
    }
    
    translate([-(pcb_w/2-pcb_antenna_connector_dia/2-antenna_w_padding),pcb_d/2-pcb_antenna_connector_dia/2-antenna_d_padding,0]) ant();
        translate([-(pcb_w/2-pcb_antenna_connector_dia/2-antenna_w_padding),-(pcb_d/2-pcb_antenna_connector_dia/2-antenna_d_padding),0]) ant();
    
    // TODO: buttons
    
    // TODO: power connector
    
    // TODO: screw hole(s)
}

battery_w=35;
battery_d=79;
battery_h=24;

module battery_compartment() {
    cube([battery_w,battery_d,battery_h], center=true);
    
    // NOTE: See [insert_part] slice for space for wires
    
    // Open cut for space for usb connection a charging status led
    cube([battery_w+20,battery_d-2*10,battery_h-2*5], center=true);
}

// TODO: add connection for fan --> to plug it when working at the bench w drone!!!???

case_w=80;
case_d=111;
case_h_depth_for_lcd=1;
case_h_depth=2;
case_lcd_inner_isolation_layer_depth=2;
case_h=
    case_h_depth_for_lcd+
    lcd_panel_h+
    case_lcd_inner_isolation_layer_depth+
    battery_h+
    case_h_depth; // NOTE: mind isolation between [pcb_antenna_back_legs] and [lcd_panel]!!!
case_inner_slice_wall=case_h_depth+2;
top_battery_wall_h=2;

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
            translate([-case_w/2+battery_w/2+case_h_depth,0,battery_h/2-(+case_h/2-case_h_depth)]) battery_compartment();
        }
    }

    module case_w_pcb_and_bat_lcd(label=false) {
        difference() {
            case_w_pcb_and_bat();
            translate([((lcd_panel_w-lcd_screen_w)/2-lcd_screen_w_padding),0,case_h/2-case_h_depth_for_lcd]) lcd_panel(label);
        }
    }
    
    
    // TODO: buttons
    
    // TODO: usb hole
    
    // TODO: screws
    
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
            case_w_pcb_and_bat_lcd(label);
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
    
    pcb_cap_h=case_h/2-case_h_depth-pcb_h+.01;
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
    
    translate([0,0,-separate]) if (!place) pcb_cap(); else translate([-case_w-separate,0,pcb_cap_h+separate]) rotate([0,0,0]) pcb_cap();
}


sliced_case(place=false);
