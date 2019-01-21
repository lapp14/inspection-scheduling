USE [HedgehogManager]
GO

CREATE PROCEDURE dbo.sp_schedulingCheckUserPermissions
	@USERNAME		varchar(50)  = ''
AS

SELECT
	usr.Id,
	usr.LastName,
	usr.FirstName,
	LOWER(usr.Username) AS 'Username',
	usr.IsActive,
	usr.WorkEmailAddress,
		
	(SELECT
		COUNT(*)
		FROM [HedgehogNiagara].dbo.[UserRole] prm
		JOIN [HedgehogNiagara].dbo.[Role] rle ON prm.RoleId = rle.Id
		WHERE
		prm.UserId = usr.Id
		AND rle.Name IN (
			'Administrators',
			'System Administrator'
		)
	) AS 'Admin',
	
	(SELECT
		COUNT(*)
		FROM [HedgehogNiagara].dbo.[UserRole] prm
		JOIN [HedgehogNiagara].dbo.[Role] rle ON prm.RoleId = rle.Id
		WHERE
		prm.UserId = usr.Id
		AND rle.Name LIKE '%Management%'
	) AS 'Management',

	(SELECT
		COUNT(*)
		FROM [HedgehogNiagara].dbo.[UserRole] prm
		JOIN [HedgehogNiagara].dbo.[Role] rle ON prm.RoleId = rle.Id
		WHERE
		prm.UserId = usr.Id
		AND rle.Name LIKE 'PHI%'
	) AS 'HealthInspector',

	(SELECT
		COUNT(*)
		FROM [HedgehogNiagara].dbo.[UserRole] prm
		JOIN [HedgehogNiagara].dbo.[Role] rle ON prm.RoleId = rle.Id
		WHERE
		prm.UserId = usr.Id
		AND rle.Name LIKE '%Team Lead%'
	) AS 'TeamLead',

	(SELECT
		COUNT(*)
		FROM [HedgehogNiagara].dbo.[UserRole] prm
		JOIN [HedgehogNiagara].dbo.[Role] rle ON prm.RoleId = rle.Id
		WHERE
		prm.UserId = usr.Id
		AND rle.Name IN (
			'Administrative Staff'
		)
	) AS 'AdministrativeAssistant'

FROM	[HedgehogNiagara].dbo.[User] usr
WHERE	usr.username = @USERNAME

GO

GRANT EXECUTE ON dbo.sp_schedulingCheckUserPermissions TO hh_reader
GO