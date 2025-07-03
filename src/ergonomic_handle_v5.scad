/*
Ergonomic handle
by Alex Matulich
Verson 5.1, May 2022

On Thingiverse: https://www.thingiverse.com/thing:5330170
On Printables: https://www.printables.com/model/154837

An ergonomic handle distributes the hand contact pressure as evenly as possible.

The dimensions in this model are based on several research papers using anthropometric data from various populations around the world. The handle profile is based on a 2020 study in which gripping hands were measured with a contour gauge to derive the correct curves for an ergonomic handle.

All of these studies are cited and linked in my blog article "[Whose hands are biggest? You may be surprised.](https://www.nablu.com/2022/03/whose-hands-are-biggest-you-may-be.html)"

I expanded on the handle contour study by generalizing it to be scalable to any size of hand. Knowing that the handle height is based on metacarpal breadth (hand width) and the handle cross section sizes are based on hand length, one can generate vertical and horizontal scale factors for the curve control points given in the study, and thereby obtain a handle scaled correctly to any size hand.

If you want a longer handle, then specify a bigger hand width. If you want a thicker handle, specify a longer hand length.

Updated April 2022 to include finger grooves, for more evenly distributed contact pressure on fingers when pulling on the handle.
Updated May 2022 to remove top-most ridge in finger grooves, unnecessary for thumb.

USAGE:
Place this in a searchable location, like the same directory as your script, and near the top, put this line:

use <ergonomic_handle_v5.scad>

Modules are as follows:

------------------------------------
ergonomic_handle(hand_length=185, hand_width=86, flair=true, bottomcapext=0, topext=0, groovespc=0, tiltangle=110, fn=64, halfrotate=false);

Renders the body of an ergonimic handle. The handle is oriented so that the top surface is centered at the origin.
Parameters:
 hand_length = length of hand from tip of middle finger to first crease on wrist. Defaults to default_hand_length() setting below.
 hand_width = metacarpal breadth; width of the four fingers where they meet the palm. Defaults to default_hand_width() setting below.
 flair = true to flare out the top and bottom of front edge, for better pull force. When flare=false, the handle is generated as described in the referenced study. Defaults to fwd_flair.
 bottomcapext = bottom cap extension. 0=flat bottom (default). Suggest values 3 to 8.
 topext = top extension, curves extrapolated upward by this amount. 0=no extension (default). The extension extends above the origin.
 groovespc = groove spacing for improved grip. 0=none (default, or if fingergroove=true). Suggest 6-10 mm spacing. Grooves are 1.2 mm wide and 0.6 mm deep.
 fingergroove = finger grooves. false=no finger grooves (default). true=include (this disables groovespc). WARNING: Enabling this setting causes the handle to fit ONLY the hand for which it is sized! The grooves are un-ergonomic and uncomfortable when the handle size doesn't match the hand.
 tiltangle = handle tilt angle. 110° (default) recommended. Should be no less than 90.
 fn = number of facets (default 64) in elliptical cross section as well as vertical slices. Vertical slices are always 128 if fingergroove=true.
 halfrotate = whether to rotate polygon vertices half of a segment around the ellipse (default false). Useful only for overlapping two low-poly handles for interesting textures (see demo).
 
------------------------------------
ergonomic_handle_top_ellipse(hand_length, hand_width, topext, tiltangle, fn);

Returns a polygon corresponding to the top surface of the handle (including extension).
Parameters are the same as described above. All have defaults if omitted.

------------------------------------
ergonomic_handle_bottom_ellipse(hand_length, hand_width, tiltangle, fn);

Returns a polygon corresponding to the bottom surface of the handle (excluding bottom cap extension). Useful when not using a bottom cap and you want to match something with the bottom of the handle.
Parameters are the same as described above. All have defaults if omitted.

In addition, ergonomic_handle_height(hand_width) may be used to get the height of the basic handle body without extensions. This is the same as hand_width * metacarpal_expansion.

The handle is rendered with the top center at origin. The bottom of the handle (excluding extension cap) is ergonomic_handle_height() below the origin.
*/


// ---------- demo ----------

// default handle with no finger grooves
//translate([0,-90,0]) ergonomic_handle(hand_length=178, hand_width=79.4, fingergroove=false);

// low-facet handle with grooves overlayed on low-facet handle without grooves, with finger-grooves and end cap
//translate([0,0,0]) union() {
//    ergonomic_handle(hand_length=178, hand_width=79.4, bottomcapext=6, groovespc=0, fingergroove=true, fn=14, halfrotate=false);
//    ergonomic_handle(hand_length=178, hand_width=79.4, bottomcapext=6, groovespc=7, fingergroove=false, fn=14, halfrotate=true);
//}
// grooved handle with top extension, bottom cap, and matching structure on top surface
//translate([0,90,0]) {
//    ergonomic_handle(hand_length=178, hand_width=79.4, bottomcapext=6, topext=10, groovespc=6);
//    translate([0,0,10]) linear_extrude(20, scale=0.8) ergonomic_handle_top_ellipse(hand_length=177.9, hand_width=79.4, topext=10);
//}

// ---------- default parameters (overridden in module arguments) ----------

/*
These hand dimensions (186, 85) were calculated from data found in various journal articles, broken down by nationality: Bangladeshi, Czech, Filipino, German, central Indian, East Indian, Iranian, Korean, Jordanian, Mexican, Taiwanese, Turkish, and Vietnamese. The average male hand length is 186 mm (range 173-198) and breadth is 85 mm (range 78-98). The average female hand length is 170 mm (range 161-180) and breadth is 76 mm (range 68-92). Using the average male size should also cover nearly all adult females and all children.

Of the data available about nationalities, when plotted by hand area (length x width) the populations sort themselves into three obvious groups that have similar hand sizes. Vietnamese and Indian females have the smallest hands, followed closely by Turkish and Bangladeshi females. Filipino males seem to be an outlier with the largest hands. Other than Filipino males, the group with the largest hands includes Czech, Iranian, Jordanian, Turkish, and German males, as well as Filipino females.
*/

metacarpal_expansion = 1.12;    // typical metacarpal breadth expansion in grip position (10%-15%)

fwd_flair = true;       // default flair for forward profile; false gives handle in the research study - recommend flair=true

module dummy() {}       // stop the customizer here if it's being used

groovedepth = 0.6;      // depth of grooves, if used; width is double of this
bottomcapscale = 0.3;   // size of bottom-most disc of bottom cap, as a fraction of handle bottom cross-section

// ---------- initialization ----------

// Handle curve coefficients

ehandle_coeff_default = [   // coefficents for default handle based on all test subjects

    // curve E (forward profile)
    [ 0.10820685778527288,
     7.8071566553000377e-002,
    -0.11713845806508627 ],
    // curve F (side profile)
    [ 8.9094997189434533e-002,
    -0.23994552971632244,
     1.0934064033888202,
    -1.5902142712055265,
     0.70892877695967604 ],
    // curve G (rear profile)
    [ 0.10820685778528655,
    -0.46856937731734472,
     1.9272376487779372,
    -2.9629722410641546,
     1.4995260044545953 ]
];

ehandle_coeff_fwdflair = [  // coefficients for handle with forward profile flared at the ends

    // curve E - assumes 12% metacarpal expansion
    [0.11246945332942532,
    -1.8795070341676573e-002,
     0.36187545606899507,
    -0.83803954628607691,
     0.46058029602811634],
     // curve F
     ehandle_coeff_default[1],
     // curve G
     ehandle_coeff_default[2]
];

// ---------- modules ----------

// render the handle

module ergonomic_handle(
    hand_length=default_hand_length(), hand_width=default_hand_width(), flair=fwd_flair, bottomcapext=0, topext=0, groovespc=0, fingergroove=false, tiltangle=110, fn=64, halfrotate=false) {
    ehdcoeff = flair ? ehandle_coeff_fwdflair : ehandle_coeff_default;
    ecof = hand_length * ehdcoeff[0];   // scaled front profile coefficients
    fcof = hand_length * ehdcoeff[1];   // scaled side profile coefficients
    gcof = hand_length * ehdcoeff[2];   // scaled rear profile coefficients
    ehlen = ergonomic_handle_height(hand_width); // length of handle
    bcapext = bottomcapext/ehlen;   // unit-scaled end cap extension
    t_ext = topext/ehlen;           // unit-scaled top extension
    tfwx = fingergroove ? trochoid(0, ehlen) : 0;
    bfwx = fingergroove ? trochoid(ehlen, ehlen) : 0;
    vfn = fingergroove ? 128 : fn;

    estack = [ // stack of ellipse cross sections
       // top extension, if any
        if (topext > 0)
            for(z=[-t_ext:1/fn:-0.01/ehlen])
                let(xmin = polynomial(gcof, z),
                    xmax = polynomial(ecof, z),
                    ymax = polynomial(fcof, z))
                    elev_ellipse(xmin, xmax, ymax, z*ehlen, tiltangle, fn, tfwx, halfrotate),

        // main body of handle
        for(i=[0:vfn])
            let(z=i/vfn,
                fwx = fingergroove ? trochoid(z*ehlen, ehlen) : 0,
                xmin = polynomial(gcof, z),
                xmax = polynomial(ecof, z),
                ymax = polynomial(fcof, z))
                    elev_ellipse(xmin, xmax, ymax, z*ehlen, tiltangle, fn, fwx, halfrotate),

        // bottom cap, if any
        if (bottomcapext > 0)
            for(z=[1+0.5/ehlen:1/ehlen:1+bcapext-0.01/ehlen])
                let(scl = bottomcapscale+(1-bottomcapscale)*cos(90*(z-1)/bcapext), xmin = scl*polynomial(gcof, z), xmax = scl*polynomial(ecof, z), ymax = scl*polynomial(fcof, z))
                    elev_ellipse(xmin, xmax, ymax, z*ehlen, tiltangle, fn, bfwx, halfrotate),
        // last ellipse of bottom cap
        if (bottomcapext > 0)
            let(z=1+bcapext, scl=bottomcapscale, xmin = scl*polynomial(gcof, z), xmax = scl*polynomial(ecof, z), ymax = scl*polynomial(fcof, z))
                elev_ellipse(xmin, xmax, ymax, z*ehlen, tiltangle, fn, bfwx, halfrotate)
    ];
    // render the object right-side-up
    rotate([0,180,0]) difference() {
        polyhedron_stack(estack);
        if (groovespc > 0 && !fingergroove) for(h = [1.5*groovespc:groovespc:ehlen-groovespc]) groove_ellipse(h);
    }

    module groovecutter() {
        polygon(points = [ [-groovedepth,0], [4-groovedepth,4], [4-groovedepth,-4] ] );
    }

    module groove_ellipse(ht) {
        let(z=ht/ehlen,
            xmin = polynomial(gcof, z),
            xmax = polynomial(ecof, z),
            ymax = polynomial(fcof, z),
            semimajoraxis = 0.5*(xmax+xmin))
                multmatrix(m = [
                [1, 0, cos(tiltangle), semimajoraxis-xmin+ht*cos(tiltangle) ],
                [0, ymax/semimajoraxis, 0, 0],
                [0, 0, 1, ht],
                [0, 0, 0, 1] ] )
                    rotate([0,0,180]) rotate_extrude(angle=360, $fn=fn, convexity=4)
                        translate([semimajoraxis,0,0]) groovecutter();
    }
}

// Build a polyhedron object from a stack of polygons. It is assumed that each polygon has [x,y,z] coordinates as its vertices, and the ordering of vertices follows the right-hand-rule with respect to the direction of propagation of each successive polygon.

module polyhedron_stack(stack) {
    nz = len(stack); // number of z layers
    np = len(stack[0]); // number of polygon vertices
    facets = [
        [ for(j=[0:np-1]) j ], // close first opening
        for(i=[0:nz-2])
            for(j=[0:np-1]) let(k1=i*np+j, k4=i*np+((j+1)%np), k2=k1+np, k3=k4+np)
                [k1, k2, k3, k4],
        [ for(j=[np*nz-1:-1:np*nz-np]) j ], // close last opening 
    ];
    polyhedron(flatten(stack), facets, convexity=6);
}

// return polygon of top ellipse (including extension)

module ergonomic_handle_top_ellipse(hand_length=default_hand_length(), hand_width=default_hand_width(), flair=fwd_flair, fingergroove=true, topext=0, tiltangle=110, fn=64, halfrotate=false) {
    coeff = hand_length * (flair ? ehandle_coeff_fwdflair : ehandle_coeff_default);
    top = -topext / ergonomic_handle_height(hand_width);
    tfwx = fingergroove ? trochoid(0, ergonomic_handle_height(hand_width)) : 0;
    p3d = elev_ellipse(polynomial(coeff[2], top), polynomial(coeff[0], top), polynomial(coeff[1], top), -topext, tiltangle, fn, tfwx, halfrotate);
    p2d = [ for(a=p3d) [ -a[0], a[1] ] ];
    polygon(points=p2d);
}

// return polygon of bottom ellipse (EXCLUDING bottom cap extension)

module ergonomic_handle_bottom_ellipse(hand_length=default_hand_length(), hand_width=default_hand_width(), flair=fwd_flair, fingergroove=true, tiltangle=110, fn=64, halfrotate=false) {
    coeff = hand_length * (flair ? ehandle_coeff_fwdflair : ehandle_coeff_default);
    ehlen = ergonomic_handle_height(hand_width);
    bfwx = fingergroove ? trochoid(ehlen, ehlen) : 0;
    p3d = elev_ellipse(polynomial(coeff[2], 1), polynomial(coeff[0], 1), polynomial(coeff[1], 1), ergonomic_handle_height(hand_width), tiltangle, fn, bfwx, halfrotate);
    p2d = [ for(a=p3d) [ -a[0], a[1] ] ];
    polygon(points=p2d);
}

// ---------- functions ----------

// default gender-based hand dimensions

function default_hand_length(female=false) = female ? 171 : 186;
function default_hand_width(female=false) = female ? 76 : 85;

// height of handle without extensions

function ergonomic_handle_height(hand_width=default_hand_width()) = hand_width * metacarpal_expansion;

// polynomial evaluation at x, given any number of coefficents c[0]...c[degree]
// usage: y = polynomial(coefficients, x);

function polynomial(cof, x, sum=0, indx=undef) =
    let(i = indx==undef ? len(cof)-1 : indx)
        i == 0 ? cof[0] + sum : polynomial(cof, x, x*(sum+cof[i]), i-1);

// elliptical cross section of handle at elevation z

function elev_ellipse(xmin, xmax, ymax, z, tiltangle, fn=64, fwd_ext=0, halfrotate=false) = let(
    semimajor = 0.5*(xmax+xmin),
    fwd_semimajor = semimajor+fwd_ext,
    yscl = ymax/semimajor,
    hr = halfrotate ? 0 : 180/fn,
    xoff = z*cos(tiltangle) + xmax - semimajor ) [
        for(a=[-90+hr:360/fn:89.9])
            [ fwd_semimajor*cos(a)+xoff, yscl*semimajor*sin(a), z ],
        for(a=[90+hr:360/fn:269.9])
            [ semimajor*cos(a)+xoff, yscl*semimajor*sin(a), z ]        
    ];

// flatten an array of arrays

function flatten(l) = [ for (a = l) for (b = a) b ] ;

// trochoid finger groove functions

// finger width porportions from anthropometric data
thumbfrac = 0.231959853553746;      // thumb fraction of hand width
forefingerfrac = 0.200542328752527; // forefinger fraction of hand width
fingwidfrac = [
/* 0.261856394119384, 0.262553059392204, 0.251706774167261, 0.22388377232115,0.22388377232115 // four fingers only - doesn't work well */

    // thumb plus four fingers
    0.5*(thumbfrac+forefingerfrac),
    0.5*(thumbfrac+forefingerfrac), // split total width of thumb+forefinger
    0.201238475943949,  // middle finger
    0.193454805146993,  // ring finger
    0.172804536602786,  // pinky
    0.172804536602786   // copy pinky to avoid array index overrun in trochoid()
];
echo(fingwidfrac);

trochoid_amp = 0.65; // trochoid amplitude, must be between 0.5 and 0.9

// finger grooves are four trochoids of different sizes blended together end-to-end
function trochoid(z_elev, handwid) = let(
    fdata = getfingindex(max(0,z_elev), handwid),
    fi = fdata[0],
    width = fingwidfrac[fi] * handwid,
    nextwid = fingwidfrac[fi+1] * handwid,
    r = width / (2*PI),
    b = trochoid_amp * r,
    nextb = trochoid_amp * nextwid / (2*PI),
    accumwid = fdata[1]*handwid,
    z = z_elev - accumwid,
    zfrac = z/width,
    theta = findtrochtheta(z, r, b, 2*PI*zfrac),
    thetadeg = fi==0 && theta<PI ? 180 : theta*180/PI, // 5.1: remove top knuckle
    interpb = zfrac*(nextb-b)+b,
    y = interpb + interpb*cos(thetadeg))
        /*(fi==0 && thetadeg<180) ? 0.01  // special case for thumb
            : */1.1 * y + 0.2;

// for a give z elevation, return the corresponding finger index 0-4
function getfingindex(z, handwid, i=0, accumwid=0) = let(
    widfrac = accumwid+fingwidfrac[i],
    wid = widfrac * handwid)
        z <= wid || i==3 ? [i, accumwid] : getfingindex(z, handwid, i+1, widfrac);

// for a given z elevation, find the corresponding trochoid rotation angle - no closed-form solution for this, so using Newton-Raphson iterative method
function findtrochtheta(z, r, b, theta=PI, n=0) = let(
    tdeg = theta * 180 / PI,
    newtheta = theta - (r*theta - b*sin(tdeg) - z) / (r - b*cos(tdeg))
    ) abs(newtheta-theta) < 0.001 || n >= 8 ? newtheta : findtrochtheta(z, r, b, newtheta, n+1);

//color("blue") polygon(points=[ for(z=[0:0.1:100]) [ z, trochoid(z, 100) ], [100, 0], [0,0] ]);