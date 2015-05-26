// Perform a plane-change maneuver to new inclination.
// Derived from https://code.google.com/p/virtualagc/wiki/BasicsOrbitalMechanics

// Givens:
//   Orbit is circular.
//   New inclination is in the range [-90..90]
// Notes:
//   Limit change to 60 degrees (else launching a new vessel takes less dV!)

// Desired new inclination (degrees)
parameter inc.

// Convert a position from SHIP-RAW to SOI-RAW frame.
function soiraw {
  parameter ship.
  parameter pos.

  return pos - ship:obt:body:position.
}

// Find orbital velocity at a given position relative to reference body's CENTER
// (vector from center, not altitude above surface!)
function obtvelpos {
  parameter obt.
  parameter pos.

  local mu is constant():G * obt:body:mass.

  return sqrt( mu * ( (2 / pos:mag) - (1 / obt:semimajoraxis) ) ).
}

// Find time of equatorial ascending/descending node of ship's orbit.
function obtequnode {
  local t0 is time.
  local p0 is soiraw(ship, ship:obt:position).
  local v0 is ship:obt:velocity:surface.

  local dt is ship:obt:period / 2.
  set t to t0 + ship:obt:period.

  local p0 is soiraw(ship, ship:obt:position).
  local v0 is ship:obt:velocity:surface.
  local p1 is soiraw(ship, positionat(ship, t)).
  local v1 is soiraw(ship, velocityat(ship, t):orbit).
  local iter is 0.

  until abs(p1:y - p0:y) < 10 {
    set iter to iter + 1.

    if ((p0:y > 0) and (p1:y < 0) and (dt * v0:y < 0)) or
       ((p0:y < 0) and (p1:y > 0) and (dt * v0:y > 0)) {
      set dt to -dt / 2.
    } else {
      set dt to dt / 2.
    }
    set t to t + dt.

    set p1 to soiraw(ship, positionat(ship, t)).
    set v1 to soiraw(ship, velocityat(ship, t):orbit).

    if iter >= 32 {
      print "obtequnode: Can't find solution after 32 iterations!".
      return 1 / 0.
      break.
    }
  }

  return t.
}

// Find time of equatorial node
local andn is obtequnode():seconds.
local vandn is velocityat(ship, andn):orbit.
local nd is 0.

// Find delta v for plane-change from circular orbit
local theta is (inc - ship:obt:inclination).
local v is vandn:mag.
local dv is 2 * v * sin(theta / 2).

if vandn:y > 0 {
  // burn normal at ascending node
  set nd to node(andn, 0, -dv, 0).
} else {
  // burn anti-normal at descending node
  set nd to node(andn, 0, dv, 0).
}

add nd.
