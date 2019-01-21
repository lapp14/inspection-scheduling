/**
 *	NRSQLD08
 *	DB: HedgehogManager
 */

USE [HedgehogManager]
GO

CREATE PROCEDURE dbo.sp_schedulingFacilityOverview 
	--@STARTDATE		datetime = NULL
	--,@ENDDATE		datetime = NULL
	@YEAR			int = 9999
	,@CATEGORY		varchar(50)  = ''
	,@TYPE			varchar(50)  = ''
	,@RISK			varchar(20)  = -1
	,@AREA			varchar(10)  = ''
	,@INSPECTOR		varchar(100) = ''
	,@SEASONALITY	varchar(50)  = ''
AS

/*
DECLARE @YEAR AS int
DECLARE @CATEGORY AS varchar(50)
DECLARE @TYPE AS varchar(50)
DECLARE @RISK AS int
DECLARE @AREA AS varchar(10)
DECLARE @INSPECTOR AS varchar(100)
DECLARE @SEASONALITY AS varchar(50)  = ''
SET		@YEAR = 2018
SET		@CATEGORY = 'All'
SET		@TYPE = 'All'
SET		@RISK = -1
SET		@AREA = 'All'
SET		@INSPECTOR = ''
SET		@SEASONALITY = ''

*/
SELECT
	fac.Id AS 'FacilityId',
	fac.Number AS 'FacilityNumber',
	fac.FacilityName,

	--Only select one inspector that is responsible for this facility.
	ISNULL((SELECT TOP 1 phi.LastName + ', ' + phi.FirstName
	FROM	[HedgehogNiagara].[dbo].WorkAreaServiceProvider wsp

	LEFT JOIN	[HedgehogNiagara].[dbo].[User] phi
		ON	wsp.UserId = phi.Id

		WHERE
			wrk.Id = wsp.WorkAreaId), '') AS 'Inspector',

	ISNULL(wrk.Description, '-') AS 'Area',
	cat.Description AS 'Category',
	ftp.Description AS 'Type',

	CASE fac.RiskRating 
		WHEN 0 THEN 'Unassessed'
		WHEN 1 THEN 'Low'
		WHEN 2 THEN 'Moderate'
		WHEN 3 THEN 'High'
	END AS 'Risk',

	CASE WHEN fac.RiskRating = 1
		THEN ftp.LowRiskInspectionPeriod / CASE ftp.LowRiskInspectionFrequency WHEN 0 THEN 1 WHEN NULL THEN 1 ELSE ftp.LowRiskInspectionFrequency END
		WHEN fac.RiskRating = 2
		THEN ftp.ModerateRiskInspectionPeriod / CASE ftp.ModerateRiskInspectionFrequency WHEN 0 THEN 1 WHEN NULL THEN 1 ELSE ftp.ModerateRiskInspectionFrequency END
		WHEN fac.RiskRating = 3
		THEN ftp.HighRiskInspectionPeriod / CASE ftp.HighRiskInspectionFrequency WHEN 0 THEN 1 WHEN NULL THEN 1 ELSE ftp.HighRiskInspectionFrequency END
		ELSE 0
	END * 30 AS 'Freq',
			
	ISNULL(CONVERT(varchar(11), fac.NextInspectionDate, 121), 'None') AS 'NextInspection',
	--CAST(CASE WHEN fac.NextInspectionDate <= @ENDDATE THEN 1 ELSE 0 END AS bit) AS 'Required',

	-- Is facility temporarily closed?
	CASE
		(SELECT	COUNT(cls.Id)
		FROM	[HedgehogNiagara].[dbo].FacilityClosure cls
		WHERE
			cls.FacilityId = fac.Id
			AND cls.ClosureDate <= GETDATE()
			AND (
				cls.OpenDate > GETDATE()
				OR cls.OpenDate IS NULL
			)
		)
		WHEN 0 THEN 'Open'
		ELSE 'Temporarily Closed'
	END AS 'Status',
	CONVERT(varchar(10), fac.OperationStartDate, 121) AS 'OperationStartDate',
	fac.OperationsType AS 'Seasonality',
	ISNULL(fac.OperatingSchedule_FromDayOrdinal, -1) AS 'OperatingSchedule_FromDayOrdinal',
	ISNULL(fac.OperatingSchedule_FromDayOfWeek, -1) AS 'OperatingSchedule_FromDayOfWeek',
	ISNULL(fac.OperatingSchedule_FromMonthOfYear, -1) AS 'OperatingSchedule_FromMonthOfYear',
	ISNULL(fac.OperatingSchedule_ToDayOrdinal, -1) AS 'OperatingSchedule_ToDayOrdinal',
	ISNULL(fac.OperatingSchedule_ToDayOfWeek, -1) AS 'OperatingSchedule_ToDayOfWeek',
	ISNULL(fac.OperatingSchedule_ToMonthOfYear, -1) AS 'OperatingSchedule_ToMonthOfYear'

FROM	[HedgehogNiagara].dbo.[Facility] fac

JOIN	[HedgehogNiagara].dbo.FacilityType ftp
	ON	fac.FacilityTypeId = ftp.Id

JOIN	[HedgehogNiagara].dbo.FacilityCategory cat
	ON	ftp.FacilityCategoryId = cat.Id

LEFT JOIN	[HedgehogNiagara].dbo.WorkArea wrk
	ON	fac.WorkAreaId = wrk.Id

WHERE
	fac.IsActive = 1
	AND fac.FacilityName NOT LIKE 'test %'
	
	--Only select Facility Types that require inspections every year
	AND ftp.RiskAssessmentModelRepositoryId IS NOT NULL
	AND ftp.RiskAssessmentMaximumLowScore   IS NOT NULL	

	--make sure facility wasnt opened after end date interval
	AND YEAR(fac.CreatedDateTime) <= @YEAR

	--search parameters
	AND (
		@CATEGORY = 'All'
		OR @CATEGORY = ''
		OR @CATEGORY IS NULL		
		OR cat.Description = @CATEGORY
	)

	AND (
		@TYPE = 'All'
		OR @TYPE = ''
		OR @TYPE IS NULL
		OR ftp.Description = @TYPE
	)

	AND (
		   (@AREA = 'All')
		OR @AREA = ''
		OR (wrk.Description LIKE '%' + @AREA + '%')
	)
	AND (
		   (@SEASONALITY = '')
		OR (@SEASONALITY = 'All')
		OR (fac.OperationsType = @SEASONALITY)
	)
	
	AND (--Search inspector
		   (@INSPECTOR = '')
		OR (@INSPECTOR IS NULL)
		OR (@INSPECTOR = 'All')
		OR (@INSPECTOR = 'Unassigned' AND fac.WorkAreaId IS NULL)
		OR (SELECT COUNT(*)
				FROM [HedgehogNiagara].[dbo].WorkAreaServiceProvider wsp
				JOIN [HedgehogNiagara].[dbo].WorkArea wrk	ON wsp.WorkAreaId = wrk.Id
				JOIN [HedgehogNiagara].[dbo].[User] phi		ON phi.Id = wsp.UserId
			 WHERE 
				phi.LastName + ', ' + phi.FirstName = @INSPECTOR			
				AND fac.WorkAreaId = wsp.WorkAreaId
		) > 0	
	)

	AND (--Risk assessments
		@RISK < 0 
		OR fac.RiskRating = @RISK
	)
GO

GRANT EXECUTE ON sp_schedulingFacilityOverview TO hh_reader
GO

/**
 *	Program query. This is the code in HedgehogManager in hedgehogmanager.db.Database
 */

/*

EXEC [HedgehogManager].[dbo].[sp_schedulingFacilityOverview] 
	@YEAR  = 2018, @SEASONALITY = 'Seasonal'
	,@CATEGORY = ''
	,@TYPE = ''
	,@RISK = -1
	,@AREA = ''
	,@INSPECTOR = ''

EXEC [HedgehogManager].[dbo].[sp_schedulingFacilityOverview] @YEAR = 2018
*/