USE [ODW]
GO
/****** Object:  UserDefinedFunction [dbo].[CONTACT_PRIMARY_GUID]    Script Date: 12/1/2016 9:20:13 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[CONTACT_PRIMARY_GUID](@ACCOUNTID_IN VARCHAR(18))

RETURNS varchar(18)
AS
BEGIN
     DECLARE @CONTACT1 VARCHAR(18);
     SELECT TOP 1 @CONTACT1 =   ID
		   from Contact C
          where C.ACCOUNTID = @ACCOUNTID_IN
            and C.RC_BIOS__MINOR_CHILD__C = 0
            and C.RC_BIOS__ACTIVE__c = 1
            and C.RC_BIOS__PREFERRED_CONTACT__C = 1
			ORDER BY CreatedDate;
     RETURN @CONTACT1;
END;

GO
