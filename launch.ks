/////////////////////////////////////////////////////////////////////////////
// Launch into parking orbit
/////////////////////////////////////////////////////////////////////////////
// Ascends to a stable circular orbit.
/////////////////////////////////////////////////////////////////////////////

run once lib_ui.

uiBanner("Mission", "Ascend from " + body:name).
run launch_asc(body:atm:height + (body:radius / 4)).
