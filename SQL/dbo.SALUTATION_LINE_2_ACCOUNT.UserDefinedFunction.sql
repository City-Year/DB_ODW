USE [ODW]
GO
/****** Object:  UserDefinedFunction [dbo].[SALUTATION_LINE_2_ACCOUNT]    Script Date: 12/1/2016 9:20:14 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[SALUTATION_LINE_2_ACCOUNT](@ACCOUNTID_IN varchar(18), @SALUTATION_TYPE_IN VARCHAR(255)) RETURNS varchar(255)

BEGIN
     DECLARE @SAL_LINE_2 VARCHAR(255);
            SELECT TOP 1 @SAL_LINE_2 = replace(rc_bios__salutation_line_2__C,',','')
              FROM rc_bios__salutation__C
             WHERE rc_bios__ACCOUNT__C = @ACCOUNTID_IN
               AND RC_BIOS__SALUTATION_TYPE__C = @SALUTATION_TYPE_IN
             order by CreatedDate DESC;
     RETURN @SAL_LINE_2;
    END;
GO
