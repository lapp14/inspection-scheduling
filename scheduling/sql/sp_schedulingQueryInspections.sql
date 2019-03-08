/**
 *	NRSQLD08
 *	DB: HedgehogManager
 */

USE [HedgehogManager]
GO

CREATE PROCEDURE dbo.sp_schedulingQueryInspections
	@FACILITY_ID nvarchar(256) = NULL,
	@YEAR int
AS

SELECT
	ins.FacilityId,
	ins.Id AS 'InspectionId',
	ins.Number AS 'InspectionNumber',
	CONVERT(varchar(10), ins.StartDateTime, 121) AS 'InspectionDate',
	YEAR(ins.StartDateTime) AS 'Year',
	DATEPART(m, ins.StartDateTime) AS 'Month',
	ins.IsCompliance,
	ins.InspectorId,
	phi.LastName + ', ' + phi.FirstName AS 'Inspector',
	phi.Username AS 'InspectorUsername',
	itp.Description AS 'InspectionType'

FROM	[HedgehogNiagara].dbo.[Inspection] ins

JOIN	[HedgehogNiagara].dbo.[InspectionType] itp
	ON	ins.InspectionTypeId = itp.Id

JOIN	[HedgehogNiagara].dbo.[User] phi
	ON	ins.InspectorId = phi.Id

WHERE
	ins.FacilityId = @FACILITY_ID
	AND ins.VoidedDateTime IS NULL	
	AND YEAR(ins.StartDateTime) = @YEAR
ORDER BY
	ins.StartDateTime
GO


GRANT EXECUTE ON dbo.sp_schedulingQueryInspections TO hh_reader
GO
