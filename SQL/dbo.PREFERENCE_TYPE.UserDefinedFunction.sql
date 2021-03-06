USE [ODW]
GO
/****** Object:  UserDefinedFunction [dbo].[PREFERENCE_TYPE]    Script Date: 12/1/2016 9:20:14 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[PREFERENCE_TYPE](@CATEGORY_IN VARCHAR(255), @TYPE_IN VARCHAR(255)) RETURNS varchar(255)

BEGIN
     DECLARE @RESULT VARCHAR(18);
     SELECT @RESULT = 
    (
      SELECT rc_bios__type__c
        FROM s_preference_account
       WHERE     isnull(RC_BIOS__START_DATE__c, GetDate()) >= GetDate()
             AND isnull(rc_bios__end_date__c, GetDate()) <= GetDate()
             AND rc_bios__active__c = 'true'
             AND rc_bios__category__c = @CATEGORY_IN
             AND rc_bios__type__c = @TYPE_IN
      );
     RETURN @RESULT;
    END;
	

GO
