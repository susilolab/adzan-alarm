create table setting(
id integer primary key autoincrement,
play_adzan integer,
lat real,
lng real,
city_name text,
time_zone real,
start_minimized integer,
notify_set integer,
notify_minute integer,
calc_method integer,
adzan_subh text,
adzan_normal text
);