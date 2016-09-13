CREATE TABLE IF NOT EXISTS "users" (
	`uid`	INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
	`user`	TEXT NOT NULL UNIQUE,
	`email`	TEXT NOT NULL,
	`hash`	TEXT NOT NULL
);
CREATE INDEX IF NOT EXISTS index_users ON users (user);

CREATE TABLE IF NOT EXISTS "names" (
	`uid`	INTEGER NOT NULL,
	`name`	TEXT NOT NULL,
	`left_max`	INTEGER NOT NULL DEFAULT 10,
	`right_max`	INTEGER NOT NULL DEFAULT 10,
	`count`	INTEGER NOT NULL DEFAULT 25,
	`timeout`	INTEGER NOT NULL DEFAULT 0
);
CREATE INDEX IF NOT EXISTS index_names ON names (name);

CREATE TABLE IF NOT EXISTS "stats" (
	`uid`	INTEGER NOT NULL,
	`operation`	TEXT NOT NULL DEFAULT '+',
	`timestamp`	INTEGER,
	`correct`	INTEGER,
	`count`	INTEGER,
	PRIMARY KEY(uid)
);
CREATE INDEX IF NOT EXISTS index_stats on stats (operation,timestamp);

insert into users (user,email,hash) values ("steeve", "steeve.mccauley@gmail.com", "foo");

