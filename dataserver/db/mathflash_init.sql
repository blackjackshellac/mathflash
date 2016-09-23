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
	`timeout`	INTEGER NOT NULL DEFAULT 0,
	PRIMARY KEY(`uid`)
);
DROP INDEX IF EXISTS index_names;
CREATE UNIQUE INDEX IF NOT EXISTS index_uid_name on names (uid, name);
CREATE TABLE IF NOT EXISTS "stats" (
	`uid`			INTEGER NOT NULL,
	`operation`		TEXT NOT NULL DEFAULT '+',
	`stimestamp`	INTEGER,
	`etimestamp`	INTEGER,
	`correct`		INTEGER,
	`count`			INTEGER,
	`percent`		INTEGER
);
CREATE INDEX IF NOT EXISTS index_stats on stats (operation,stimestamp);
CREATE TABLE IF NOT EXISTS "global" (
	`uid`	INTEGER NOT NULL,
	`name`	TEXT NOT NULL DEFAULT 'default',
	`operation`	TEXT NOT NULL DEFAULT '+',
	PRIMARY KEY(`uid`)
);
