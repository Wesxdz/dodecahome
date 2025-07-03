// Welcome Dodecahome

// Default settings for ATX and ITX form factor builds



// Panel index
// 0 Back upper left
// 1 Front
// 2 Back upper right
// 3 Side right
// 4 Bottom right (right back wheel)
// 5 Back right
// 6 Back (power port)
// 7 Back left
// 8 Back middle upper
// 9 Front lower (front wheel)
// 10 Side left
// 11 Bottom left (left back wheel)

// Positions/rotations of the panels calculated with
pos = [[0.5854101777076721, 0.0, 0.9472135305404663],
[1.1920929132713809e-08, 0.9472135305404663, 0.5854102373123169],
[-0.5854101777076721, 1.1920929132713809e-08, 0.9472135305404663],
[-0.9472135305404663, 0.5854101777076721, 0.0],
[-0.5854102373123169, 1.1920929132713809e-08, -0.9472135305404663],
[-0.9472135305404663, -0.5854101777076721, -1.1920929132713809e-08],
[0.0, -0.9472135305404663, -0.5854101777076721],
[0.9472135305404663, -0.5854102373123169, -1.1920929132713809e-08],
[1.1920929132713809e-08, -0.9472135305404663, 0.5854101777076721],
[0.0, 0.9472135305404663, -0.5854101777076721],
[0.9472135305404663, 0.5854101777076721, 0.0],
[0.5854101777076721, 0.0, -0.9472135305404663]];

rots = [
[0.0, -148.28252619340458, 0.0],
[58.28252330005587, -179.99999883326447, 0.0],
[6.133892063149527e-07, 148.28252619340458, 0.0],
[31.71747270143459, 90.0, 0.0],
[6.133892063149527e-07, 31.717476711648423, 0.0],
[-31.71747270143459, 89.99999927891773, 0.0],
[-58.28252330005587, -0.0, -0.0],
[-31.717476716119066, -89.99999927891773, -0.0],
[-58.28252330005587, -179.99999883326436, 0.0],
[58.28252330005587, -0.0, -0.0],
[31.71747270143459, -90.0, 0.0],
[0.0, -31.717473806595436, -0.0],
];

// These rotations align the panel edges
panel_rots = [36, -36*4.5, 0, 18 - 72*2, 180+36, -18, 18, -18, 18+72, 18+72, 18, -36];
//panel_rots = [36, -36*4.5, 0, 18, 180, -18, 18, -18, 18, 18+36, 18, 0];

// 0 is Nose Cone
// 1 is Bridge
// 2 is Life Support
// 3 is Cradle
face_groups = [0, 1, 0, 1, 3, 2, 2, 2, 0, 3, 1, 3];

// Face group palettes
pastel_gothic = ["#DB9366", "#FFBAEC", "#ADEAE6", "#93DB65"];

// 0 is Mortality Escape Pod
// 1 is Mothership
meta_groups = [0, 0, 0, 0, 1, 1, 1, 1, 0, 1, 0, 1];

unique_panel_colors = [
    "#be4a2f", "#d77643", "#ead4aa", "#e4a672", "#b86f50", "#733e39",
    "#3e2731", "#a22633", "#e43b44", "#f77622", "#feae34", "#fee761"
];

// Indicate whether standard ventilation should be cutout on a panel
vents = [true, true, true, true, true, true, true, true, true, true, true, true];

// In ROBOT MODE, the wheels are configured into a triwheel design
// Settings to configure robotic aspects and motherboard size
robot_mode = true;


build_config = "PROTOTYPE";

dihedral = 116.565;

// 1 unit is 1 cm
// ATX
// Circumradius of pentagon
panel_radius = 16;

// ITX
//panel_radius=14;

panel_thickness = .3;

panel_Z = panel_thickness/tan(116.565/2);
// inner_panel_radius = panel_radius - panel_Z;
// I'm not sure if this is correct, I just guessed
inner_panel_radius = panel_radius-(panel_thickness-panel_Z)*2;

// Hex vent

// Production
//cell_size = 0.3;
//wall_thickness = 0.1;

// Small
// cell_size = 0.4;
// wall_thickness = 0.2;

// Large
//cell_size = 0.6;
//wall_thickness = .3;

// Iterate
cell_size = 10.0;
wall_thickness = .01;

// The distance from a corner to the center of an M3 hole (for connectors)
// the radius is centered at the base corner
pcorner_dist = 3;
m3_distance_from_panel_corner = [pcorner_dist, pcorner_dist, pcorner_dist , pcorner_dist , pcorner_dist ];

// The space between the M3 screws to secure power variant vertex connector
// (Bottom of Cradle panels)
power_secure_spacing = 4.0;
// Space between M3 screws on panel corners/connector notches with 2 screws
// Front mothership and fan
// (currently this should be <= 1.8, otherwise it will not extend to the inner surface of a vertex notch
standard_secure_spacing = 1.3;

// The distance from the panel edge, which is not vented
border_edge = 1.0;

// https://en.wikipedia.org/wiki/Pentagon
eq_panel_edge_length = sqrt((5-sqrt(5))/2);
panel_edge_length = panel_radius*eq_panel_edge_length;

eq_panel_height = sqrt(5 + 2*sqrt(5))/2;
panel_height = eq_panel_height * panel_edge_length;

inner_panel_edge_length = inner_panel_radius*eq_panel_edge_length;
inner_panel_height = eq_panel_height*inner_panel_edge_length;

eq_height_vertical = sin(dihedral/2);
height_vertical = eq_height_vertical * panel_height;

height_stack = height_vertical*2;

tetra_a = 37.3774;
// 20.9052
// Tetrahedron C
magic_angle = atan(panel_edge_length/height_stack);

RAM = 128; // ;)

// Mounting bracket for wheels
bracket_height = 2.8;
bracket_start = 1.0;
bracket_width = 2.0;
insert_width = 5.0;
insert_partial = insert_width-bracket_width;

// Wheel Mount Panel Insert Offset;
// ie how far from bottom of panel to difference the wheel mount insert
wmb_pio = 5;

interior_scale = (25.9789/1.40126);
to_wheel_mount_surface = -16.9118;

brass_insert_radius = 4.8/2/10;
brass_insert_height = 4/10;

screw_clearance = 0.03;
m3_rad = 0.15+screw_clearance;

module BrassInsert()
{
    $fn=64;
    cylinder(0.4, (0.5-0.02)/2, (0.5-0.02)/2);
}

module BrassInsertHolder()
{
    $fn=64;
    cylinder(0.4, 0.5, 0.5);
}