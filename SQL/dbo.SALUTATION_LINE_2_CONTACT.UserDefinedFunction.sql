USE [ODW]
GO
/****** Object:  UserDefinedFunction [dbo].[SALUTATION_LINE_2_CONTACT]    Script Date: 12/1/2016 9:20:14 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[SALUTATION_LINE_2_CONTACT](@CONTACTID_IN varchar(18), @SALUTATION_TYPE_IN VARCHAR(255)) RETURNS varchar(240)

BEGIN
     DECLARE @SAL_LINE_2 VARCHAR(240);

          select top 1 @SAL_LINE_2 = q.salutation_line_2__c
            from
            (
            SELECT '2' ordernumber, replace(
                          case when len(c.TITLE)>1 then c.TITLE else NULL end,',',' ') salutation_line_2__c
              FROM contact c
             WHERE ID = @CONTACTID_IN
            UNION
            SELECT '1', rc_bios__salutation_line_2__c
              FROM rc_bios__salutation__c
             WHERE rc_bios__contact__c = @CONTACTID_IN
               AND RC_BIOS__SALUTATION_TYPE__c = @SALUTATION_TYPE_IN) Q 
			   order by q.ordernumber
     RETURN @SAL_LINE_2;
    END;
GO
