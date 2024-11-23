
DROP TABLE IF EXISTS extra_player_data;
CREATE TABLE extra_player_data
(
    userId BIGINT,
    comment TEXT,
    hp INT,
    isPayment INT,
    level INT,
    mainCardType INT,
    maxTotalPower INT,
    money INT,
    multiMaxTotalPower INT,
    name TEXT,
    playerId BIGINT,
    recentLoginTime TIMESTAMPTZ,
    stamina SMALLINT,
    totalMagicalAttack INT,
    totalMagicalDefense INT,
    totalPhysicalAttack INT,
    totalPhysicalDefense INT,
    totalPower INT,
    tutorialFinishTime TIMESTAMPTZ,
    createdTime TIMESTAMPTZ,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT (NOW() AT TIME ZONE 'utc'),
    PRIMARY KEY(userId)
);

DROP TABLE IF EXISTS base_player_data;
CREATE TABLE base_player_data
(
    userId BIGINT,
    exp BIGINT,
    name TEXT,
    guildDataId INT,
    comment TEXT,
    hp INT,
    isPayment INT,
    level INT,
    mainCardType INT,
    maxTotalPower INT,
    money INT,
    multiMaxTotalPower INT,
    playerId BIGINT,
    recentLoginTime TIMESTAMPTZ,
    stamina SMALLINT,
    totalMagicalAttack INT,
    totalMagicalDefense INT,
    totalPhysicalAttack INT,
    totalPhysicalDefense INT,
    totalPower INT,
    characterJobPoint BIGINT,
    tutorialFinishTime TIMESTAMPTZ,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT (NOW() AT TIME ZONE 'utc'),
    PRIMARY KEY(userId)
);

DROP TABLE IF EXISTS guilds;
CREATE TABLE guilds
(
    guildDataId INT,
    guildName TEXT,
    guildMasterUserId BIGINT,
    guildLevel INT,
    guildExp BIGINT,
    joinMember SMALLINT,
    isAutoApproval BOOLEAN,
    gvgUnlockedTime TIMESTAMPTZ,
    gvgDayType SMALLINT,
    gvgTimeType SMALLINT,
    donationNum INT,
    isRecruit BOOLEAN,
    gvgWin INT,
    gvgLose INt,
    gvgDraw INT,
    guildDescription TEXT,
    guildTactics TEXT,
    gvgPushCallComment TEXT,
    recruitComment TEXT,
    createdTime TIMESTAMPTZ,
    -- From guildRankData
    ranking INT,
    rank INT,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT (NOW() AT TIME ZONE 'utc'),
    PRIMARY KEY(guildDataId)
);

DROP TABLE IF EXISTS league_rankings;
CREATE TABLE league_rankings
(
    grandGvgMstId SMALLINT,
    guildDataId INT, 
    gvgTimeType INT,
    winNum INT,
    leaguePoint INT,
    matchPoint INT,
    rankingNum INT,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT (NOW() AT TIME ZONE 'utc'),
    PRIMARY KEY (grandGvgMstId, guildDataId)
)