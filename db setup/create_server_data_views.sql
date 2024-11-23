-- View to display players logged in since a specified date
CREATE OR REPLACE VIEW login_activity AS
WITH day_intervals AS (
    SELECT
        (SELECT MIN(recentLoginTime)::DATE FROM extra_player_data) + ( n    || ' days')::interval start_time,
        (SELECT MIN(recentLoginTime)::DATE FROM extra_player_data) + ((n+1) || ' days')::interval end_time
    from generate_series(0, ((select NOW()::date - min(recentLoginTime)::date from extra_player_data)), 1) n
)
SELECT 
    d.start_time::DATE, 
    COUNT(base.userId) AS "Logins since date",
    COUNT(base.ispayment) FILTER (WHERE base.ispayment = 1) AS "Number of paid players logged in since date"
FROM base_player_data base
RIGHT JOIN day_intervals d
    ON base.recentLoginTime::DATE >= d.start_time
GROUP BY d.start_time
ORDER BY d.start_time ASC;

-- View for player data
CREATE OR REPLACE VIEW formatted_player_data AS
    SELECT
        base_player.name AS "Name",
        base_player.level AS "Level",
        base_player.comment AS "Comment",
        guild_data.guildname AS "Legion",
        base_player.hp AS "HP",
        base_player.ispayment,
        base_player.maxtotalpower AS "Max Solo Power",
        base_player.multimaxtotalpower AS "Max Multiplayer Power",
        base_player.totalpower AS "Multiplayer Main Unit Power",
        base_player.totalmagicalattack AS "Magical Attack (Multiplayer Main Unit)",
        base_player.totalmagicaldefense AS "Magical Defense (Multiplayer Main Unit)",
        base_player.totalphysicalattack AS "Physical Attack (Multiplayer Main Unit)",
        base_player.totalphysicaldefense AS "Physical Defense (Multiplayer Main Unit)"
    FROM base_player_data base_player
    LEFT JOIN guilds guild_data ON guild_data.guilddataid = base_player.guilddataid
	ORDER BY base_player.multimaxtotalpower DESC;


-- View for guild data
CREATE OR REPLACE VIEW formatted_guild_data AS
    SELECT
        guild_data.guildname AS "Guild Name",
        guild_data.guildlevel AS "Level",
        guild_data.gvgtimetype AS "Timeslot",
        guild_data.guildexp AS "EXP",
        guild_data.rank AS "Rank (Category/Letter)",
        guild_data.ranking AS "Overall Ranking",
        guild_data.joinmember AS "Members",
        SUM(base_player.multimaxtotalpower) AS "Estimated Total CP",
        guild_data.donationnum AS "Donations",
        guild_data.gvgwin AS "Wins",
        guild_data.gvglose AS "Losses",
        guild_data.gvgdraw AS "Draws",
        guild_data.guilddescription AS "Guild Description",
        guild_data.guildtactics AS "Guild Tactic",
        guild_data.gvgpushcallcomment AS "GvG Push Call Comment",
        guild_data.recruitcomment AS "Recruitment Comment"
    FROM guilds guild_data
    LEFT JOIN base_player_data base_player ON base_player.guilddataid = guild_data.guilddataid
    WHERE guild_data.ranking != 0
    GROUP BY guild_data.guilddataid
    ORDER BY guild_data.ranking;


-- Find a guild by name (case sensitive)
SELECT * FROM guilds
WHERE position('Name' in guildname) > 0;

-- Formatted query for players in a specific guild (case sensitive)
    SELECT
        base_player.name AS "Name",
        base_player.level AS "Level",
        base_player.comment AS "Comment",
        guild_data.guildname AS "Legion",
        to_char(base_player.hp, 'FM99,999,999') AS "HP",
        base_player.ispayment,
        to_char(base_player.maxtotalpower, 'FM99,999,999') AS "Max Total Power (Solo)",
        to_char(base_player.multimaxtotalpower, 'FM99,999,999') AS "Multi Max Power (Multiplayer)",
        to_char(base_player.totalpower, 'FM99,999,999') AS "Total Power (Multiplayer Main)"
    FROM base_player_data base_player
    LEFT JOIN guilds guild_data ON guild_data.guilddataid = base_player.guilddataid
	WHERE position('Name' in guild_data.guildname) > 0
	ORDER BY base_player.multimaxtotalpower DESC;


-- Get LL rankings and guild CP estimates
    SELECT
		league.rankingnum AS "LL Rank",
			guild_data.guildname AS "Guild Name",
			guild_data.guildlevel AS "Level",
			guild_data.gvgtimetype AS "Timeslot",
			guild_data.guildexp AS "EXP",
			guild_data.rank AS "Rank (Category/Letter)",
			guild_data.ranking AS "Overall Ranking",
			guild_data.joinmember AS "Members",
			guild_data.totalcp AS "Estimated Total CP",
			guild_data.donationnum AS "Donations",
			guild_data.gvgwin AS "Wins",
			guild_data.gvglose AS "Losses",
			guild_data.gvgdraw AS "Draws",
			guild_data.guilddescription AS "Guild Description",
			guild_data.guildtactics AS "Guild Tactic",
			guild_data.gvgpushcallcomment AS "GvG Push Call Comment",
			guild_data.recruitcomment AS "Recruitment Comment"
	FROM league_rankings league
	RIGHT JOIN
	(
		SELECT
--			base_player.userid,
			SUM(base_player.multimaxtotalpower) AS "totalcp",
			guild_Data.*
		FROM guilds guild_data
		LEFT JOIN base_player_data base_player ON base_player.guilddataid = guild_data.guilddataid
		-- LEFT JOIN league_rankings league ON guild_data.guilddataid = league.guilddataid
		WHERE guild_data.ranking != 0
		GROUP BY guild_data.guilddataid
	) guild_data ON guild_data.guilddataid = league.guilddataid
	ORDER BY guild_data.totalcp DESC;