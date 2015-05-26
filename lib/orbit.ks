// Determine orbital velocity at a given altitude.
function obtvel {
  parameter obt.
  parameter alt.

  local mu is constant():G * obt:body:mass.
  local r is obt:body:radius + alt.

  return sqrt( mu * ( (2 / r) - (1 / obt:semimajoraxis) ) ).
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
