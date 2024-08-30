

lcd_panel_w=67;
lcd_panel_d=105;
lcd_panel_h=3;
lcd_screen_w=60;
lcd_screen_d=103;
lcd_screen_w_padding=1.5;
lcd_conn_strip_d=50;
lcd_conn_strip_w=2;
lcd_conn_strip_right_padding=10;

module lcd_panel() {
    
    module screen_box(h) {
        displacement=.5;
        translate([-((lcd_panel_w-lcd_screen_w)/2-lcd_screen_w_padding),0,lcd_panel_h/2+h/2-displacement]) cube([lcd_screen_w, lcd_screen_d, h], center=true);
    }
    
    translate([0,0,-lcd_panel_h/2]) {
        difference() {
            cube([lcd_panel_w, lcd_panel_d, lcd_panel_h], center=true);
            screen_box(h=1);
        }
        #screen_box(h=10);    
        
        %translate([0,40,lcd_panel_h/3]) rotate([0,0,-90]) text("LCD SCREEN");
        
        // connection strip safety box
        translate([lcd_panel_w/2,lcd_conn_strip_d/2-lcd_panel_d/2+lcd_conn_strip_right_padding,-lcd_panel_h/2]) rotate([90,0,0]) cylinder(h=lcd_conn_strip_d, r=lcd_panel_h, center=true);
    }
}

pcb_w=40;
pcb_d=103;
pcb_h=5;
pcb_antenna_connector_h=10;
pcb_antenna_connector_dia=8; // SMA diameter
pcb_antenna_back_legs=3;

module pcb() {
    // pcb itself
    translate([0,0,-pcb_h/2]) cube([pcb_w,pcb_d,pcb_h], center=true);
    
    // antennas
    module ant() {
        translate([0,0,(pcb_antenna_connector_h+pcb_h+pcb_antenna_back_legs)/2-pcb_h-pcb_antenna_back_legs])
            cylinder(h=pcb_antenna_connector_h+pcb_h+pcb_antenna_back_legs, d=pcb_antenna_connector_dia, center=true);
    }
    antenna_w_padding=2;
    antenna_d_padding=2;
    translate([-(pcb_w/2-pcb_antenna_connector_dia/2-antenna_w_padding),pcb_d/2-pcb_antenna_connector_dia/2-antenna_d_padding,0]) ant();
        translate([-(pcb_w/2-pcb_antenna_connector_dia/2-antenna_w_padding),-(pcb_d/2-pcb_antenna_connector_dia/2-antenna_d_padding),0]) ant();
    
    // TODO: buttons
    
    // TODO: power connector
    
    // TODO: screw hole(s)
}

battery_w=34;
battery_d=60;
battery_h=24;

module battery_compartment() {
    cube([battery_w,battery_d,battery_h], center=true);
    
    // TODO: space for wires
    
    // TODO: space for usb connection
    
    // TODO: is there a charging status led???
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

module case() {
    module case_w_pcb() {
        difference() {
            cube([case_w, case_d, case_h], center=true);            
            translate([case_w/2-pcb_w/2-case_h_depth,0,-(case_h/2-case_h_depth)]) rotate([180,0,0]) %pcb();
        }
    }

    module case_w_pcb_and_lcd() {
        difference() {
            case_w_pcb();
            translate([((lcd_panel_w-lcd_screen_w)/2-lcd_screen_w_padding),0,case_h/2-case_h_depth_for_lcd]) %lcd_panel();
        }
    }
    
    module case_w_pcb_and_lcd_and_bat() {
        difference() {
            case_w_pcb_and_lcd();
            translate([-case_w/2+battery_w/2+case_h_depth,0,battery_h/2-(+case_h/2-case_h_depth)]) %battery_compartment();
        }
    }
    
    case_w_pcb_and_lcd_and_bat();
    
    // TODO: buttons
    
    // TODO: screws
    
    // TODO: slice in parts
}


%case();
