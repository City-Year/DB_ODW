USE [ODW]
GO
/****** Object:  UserDefinedFunction [dbo].[CONTACT_SECONDARY_GUID]    Script Date: 12/1/2016 9:20:14 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[CONTACT_SECONDARY_GUID](@ACCOUNTID_IN VARCHAR(18))

RETURNS varchar(18)
AS
BEGIN
     DECLARE @CONTACT2 VARCHAR(18);
     SELECT TOP 1 @CONTACT2 =   ID
		   from Contact C
          where C.ACCOUNTID = @ACCOUNTID_IN
            and C.RC_BIOS__MINOR_CHILD__C = 0
            and C.RC_BIOS__ACTIVE__c = 1
            and C.RC_BIOS__PREFERRED_CONTACT__C = 0
			ORDER BY CreatedDate;
     RETURN @CONTACT2;
END;

GO
