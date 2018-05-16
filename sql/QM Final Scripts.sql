USE [QM]
GO
/****** Object:  StoredProcedure [dbo].[GetAllWorkGroups]    Script Date: 5/16/2018 6:18:22 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GetAllWorkGroups] 
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	Select workgroupid, workgroupname from workgroup where status = 1
END


GO
/****** Object:  StoredProcedure [dbo].[GetReport]    Script Date: 5/16/2018 6:18:22 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Mujeeb K S
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[GetReport] 
	@startdate datetime,
	@endDate datetime,
	@workgroupid varchar(max)
AS
BEGIN

declare @formatedStartDate datetime
set  @formatedStartDate = Cast(CONVERT(CHAR(10), @startdate, 101) as datetime)

declare @formatedEndDate datetime
set  @formatedEndDate = Cast(CONVERT(CHAR(10), @endDate, 101) as datetime) 

	--split CourtIDs into a table
	DECLARE @tbCourtIDs     table(CourtID varchar(1000) NULL)
	INSERT INTO @tbCourtIDs
	select * from dbo.SplitString(@workgroupid, ',') 

	;with CTEGetReport (starttime, endtime, mediaid, dnis, ani, updateuserid, percentscore, overallscore, reviewdate, username,
	userroleid, usertypeid, workgroupname, [description], [name], sequencenumber, questiondescription, questionnumber,
	questiontext, responserequired, questionadditionalpoint, autofailpoint, questionadditionalconditionpoint, weightedscore,
	sectionWeight, responsetext, questionWeight, questiontypedesc, questionScored)
	as     
	(SELECT DISTINCT 
                         m.starttime, m.endtime, m.mediaid, m.dnis, m.ani, r.updateuserid, r.percentscore, r.overallscore, r.reviewdate, i.username, i.userroleid, i.usertypeid, w.workgroupname, s.description, s.name, s.sequencenumber, 
                         q.questiondescription, q.questionnumber, q.questiontext, q.responserequired, q.questionadditionalpoint, q.autofailpoint, q.questionadditionalconditionpoint, sr.weightedscore, s.weight AS sectionWeight, 
                         qr.responsetext, q.weight AS questionWeight, qt.questiontypedesc, qt.scored AS questionScored
		FROM            workgroup AS w INNER JOIN
                         workgroup_iqmuser AS wi ON wi.workgroupid = w.workgroupid INNER JOIN
                         iqmuser AS i ON i.userid = wi.userid INNER JOIN
                         media AS m ON m.userid = wi.userid LEFT OUTER JOIN
                         review AS r ON r.mediaid = m.mediaid LEFT OUTER JOIN
                         sectionresult AS sr ON sr.reviewid = r.reviewid LEFT OUTER JOIN
                         section AS s ON s.sectionid = sr.sectionid LEFT OUTER JOIN
                         question AS q ON q.sectionid = s.sectionid LEFT OUTER JOIN
                         questionresult AS qr ON q.questionid = qr.questionid LEFT OUTER JOIN
                         questiontype AS qt ON qt.questiontypeid = q.questiontypeid
		WHERE (w.workgroupid IN (SELECT CourtID FROM @tbCourtIDs)) AND 
		(CAST(CONVERT(CHAR(10), m.starttime, 101) AS datetime) BETWEEN @formatedStartDate AND @formatedEndDate) AND
		(CAST(CONVERT(CHAR(10), m.endtime, 101) AS datetime) BETWEEN @formatedStartDate AND @formatedEndDate))

		select starttime, endtime, mediaid, dnis, ani, updateuserid, percentscore, overallscore, reviewdate, username,
		userroleid, usertypeid, workgroupname, [description], [name], sequencenumber, questiondescription, questionnumber,
		questiontext, responserequired, questionadditionalpoint, autofailpoint, questionadditionalconditionpoint, weightedscore,
		sectionWeight, responsetext, questionWeight, questiontypedesc, questionScored from CTEGetReport
END


GO
/****** Object:  StoredProcedure [dbo].[GetReportcsvList]    Script Date: 5/16/2018 6:18:22 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GetReportcsvList] 
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	--SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT ID, ReportGeneratedFileName, CreatedOn, CreatedBy, MethodofCreation, ReportGeneratedFullPath, ReportLocation
	FROM     ReportsGenerated order by ID desc
END

GO
/****** Object:  StoredProcedure [dbo].[GetReportDailyJob]    Script Date: 5/16/2018 6:18:22 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Mujeeb K S
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[GetReportDailyJob] 
	@startdate datetime,
	@endDate datetime,
	@workgroupid varchar(max) = null
AS
BEGIN

declare @formatedStartDate datetime
set  @formatedStartDate = Cast(CONVERT(CHAR(10), @startdate, 101) as datetime)

declare @formatedEndDate datetime
set  @formatedEndDate = Cast(CONVERT(CHAR(10), @endDate, 101) as datetime)

if (@workgroupid is null)

begin
    ;with CTEGetReport (starttime, endtime, mediaid, dnis, ani, updateuserid, percentscore, overallscore, reviewdate, username,
	userroleid, usertypeid, workgroupname, [description], [name], sequencenumber, questiondescription, questionnumber,
	questiontext, responserequired, questionadditionalpoint, autofailpoint, questionadditionalconditionpoint, weightedscore,
	sectionWeight, responsetext, questionWeight, questiontypedesc, questionScored)
	as     
	(SELECT DISTINCT 
                         m.starttime, m.endtime, m.mediaid, m.dnis, m.ani, r.updateuserid, r.percentscore, r.overallscore, r.reviewdate, i.username, i.userroleid, i.usertypeid, w.workgroupname, s.description, s.name, s.sequencenumber, 
                         q.questiondescription, q.questionnumber, q.questiontext, q.responserequired, q.questionadditionalpoint, q.autofailpoint, q.questionadditionalconditionpoint, sr.weightedscore, s.weight AS sectionWeight, 
                         qr.responsetext, q.weight AS questionWeight, qt.questiontypedesc, qt.scored AS questionScored
	FROM            workgroup AS w INNER JOIN
                         workgroup_iqmuser AS wi ON wi.workgroupid = w.workgroupid INNER JOIN
                         iqmuser AS i ON i.userid = wi.userid INNER JOIN
                         media AS m ON m.userid = wi.userid LEFT OUTER JOIN
                         review AS r ON r.mediaid = m.mediaid LEFT OUTER JOIN
                         sectionresult AS sr ON sr.reviewid = r.reviewid LEFT OUTER JOIN
                         section AS s ON s.sectionid = sr.sectionid LEFT OUTER JOIN
                         question AS q ON q.sectionid = s.sectionid LEFT OUTER JOIN
                         questionresult AS qr ON q.questionid = qr.questionid LEFT OUTER JOIN
                         questiontype AS qt ON qt.questiontypeid = q.questiontypeid
	where  
	(CAST(CONVERT(CHAR(10), m.starttime, 101) AS datetime) BETWEEN @formatedStartDate AND @formatedEndDate) AND 
    (CAST(CONVERT(CHAR(10), m.endtime, 101) AS datetime) BETWEEN @formatedStartDate AND @formatedEndDate))

	select starttime, endtime, mediaid, dnis, ani, updateuserid, percentscore, overallscore, reviewdate, username,
	userroleid, usertypeid, workgroupname, [description], [name], sequencenumber, questiondescription, questionnumber,
	questiontext, responserequired, questionadditionalpoint, autofailpoint, questionadditionalconditionpoint, weightedscore,
	sectionWeight, responsetext, questionWeight, questiontypedesc, questionScored from CTEGetReport

end
else 
begin

	;with CTEGetReport (starttime, endtime, mediaid, dnis, ani, updateuserid, percentscore, overallscore, reviewdate, username,
	userroleid, usertypeid, workgroupname, [description], [name], sequencenumber, questiondescription, questionnumber,
	questiontext, responserequired, questionadditionalpoint, autofailpoint, questionadditionalconditionpoint, weightedscore,
	sectionWeight, responsetext, questionWeight, questiontypedesc, questionScored)
	as     
	(SELECT DISTINCT 
                         m.starttime, m.endtime, m.mediaid, m.dnis, m.ani, r.updateuserid, r.percentscore, r.overallscore, r.reviewdate, i.username, i.userroleid, i.usertypeid, w.workgroupname, s.description, s.name, s.sequencenumber, 
                         q.questiondescription, q.questionnumber, q.questiontext, q.responserequired, q.questionadditionalpoint, q.autofailpoint, q.questionadditionalconditionpoint, sr.weightedscore, s.weight AS sectionWeight, 
                         qr.responsetext, q.weight AS questionWeight, qt.questiontypedesc, qt.scored AS questionScored
	FROM            workgroup AS w INNER JOIN
                         workgroup_iqmuser AS wi ON wi.workgroupid = w.workgroupid INNER JOIN
                         iqmuser AS i ON i.userid = wi.userid INNER JOIN
                         media AS m ON m.userid = wi.userid LEFT OUTER JOIN
                         review AS r ON r.mediaid = m.mediaid LEFT OUTER JOIN
                         sectionresult AS sr ON sr.reviewid = r.reviewid LEFT OUTER JOIN
                         section AS s ON s.sectionid = sr.sectionid LEFT OUTER JOIN
                         question AS q ON q.sectionid = s.sectionid LEFT OUTER JOIN
                         questionresult AS qr ON q.questionid = qr.questionid LEFT OUTER JOIN
                         questiontype AS qt ON qt.questiontypeid = q.questiontypeid
	where w.workgroupid in ( @workgroupid ) AND
	(CAST(CONVERT(CHAR(10), m.starttime, 101) AS datetime) BETWEEN @formatedStartDate AND @formatedEndDate) AND 
    (CAST(CONVERT(CHAR(10), m.endtime, 101) AS datetime) BETWEEN @formatedStartDate AND @formatedEndDate))

	select starttime, endtime, mediaid, dnis, ani, updateuserid, percentscore, overallscore, reviewdate, username,
	userroleid, usertypeid, workgroupname, [description], [name], sequencenumber, questiondescription, questionnumber,
	questiontext, responserequired, questionadditionalpoint, autofailpoint, questionadditionalconditionpoint, weightedscore,
	sectionWeight, responsetext, questionWeight, questiontypedesc, questionScored from CTEGetReport

end
END


GO
/****** Object:  StoredProcedure [dbo].[InsertReport]    Script Date: 5/16/2018 6:18:22 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[InsertReport]  

    @ReportGeneratedFileName varchar(MAX),
	@CreatedOn datetime,
	@CreatedBy varchar(MAX),
	@MethodofCreation varchar(MAX),
	@ReportGeneratedFullPath varchar(MAX),
	@ReportLocation varchar(MAX)

AS 
BEGIN 
    --SET NOCOUNT ON; 

      INSERT INTO [dbo].[ReportsGenerated] 
	  (
	   ReportGeneratedFileName,
	   CreatedOn, 
	   CreatedBy,
	   MethodofCreation,
	   ReportGeneratedFullPath,
	   ReportLocation
	  
	  ) 

VALUES (

    @ReportGeneratedFileName,
	@CreatedOn,
	@CreatedBy,
	@MethodofCreation,
	@ReportGeneratedFullPath,
	@ReportLocation
); 


END 

GO
/****** Object:  UserDefinedFunction [dbo].[SplitString]    Script Date: 5/16/2018 6:18:22 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[SplitString]
(    
      @Input NVARCHAR(MAX),
      @Character CHAR(1)
)
RETURNS @Output TABLE (
      Item NVARCHAR(1000)
)
AS
BEGIN
      DECLARE @StartIndex INT, @EndIndex INT
 
      SET @StartIndex = 1
      IF SUBSTRING(@Input, LEN(@Input) - 1, LEN(@Input)) <> @Character
      BEGIN
            SET @Input = @Input + @Character
      END
 
      WHILE CHARINDEX(@Character, @Input) > 0
      BEGIN
            SET @EndIndex = CHARINDEX(@Character, @Input)
           
            INSERT INTO @Output(Item)
            SELECT SUBSTRING(@Input, @StartIndex, @EndIndex - 1)
           
            SET @Input = SUBSTRING(@Input, @EndIndex + 1, LEN(@Input))
      END
 
      RETURN
END

GO
/****** Object:  Table [dbo].[ReportsGenerated]    Script Date: 5/16/2018 6:18:22 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ReportsGenerated](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ReportGeneratedFileName] [varchar](max) NULL,
	[CreatedOn] [datetime] NULL,
	[CreatedBy] [varchar](max) NULL,
	[MethodofCreation] [varchar](max) NULL,
	[ReportGeneratedFullPath] [varchar](max) NULL,
	[ReportLocation] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
