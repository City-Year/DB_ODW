USE [ODW]
GO
/****** Object:  UserDefinedFunction [dbo].[SALUTATION_LINE_3_CONTACT]    Script Date: 12/1/2016 9:20:14 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[SALUTATION_LINE_3_CONTACT](@CONTACTID_IN varchar(18), @SALUTATION_TYPE_IN VARCHAR(255)) RETURNS varchar(255) 
BEGIN
     DECLARE @SAL_LINE_3 VARCHAR(255);

          select @sal_line_3 = salutation_line_3
            from
            (
            SELECT '2' ordernumber, replace(
              case when len(a.name)>1 then c.name else NULL end, ',', ' ') salutation_line_3
              FROM contact c
              join account a on c.ACCOUNTID = a.id
              where a.type not in ('Individual', 'Family', 'Prospect')
                and c.ID = @CONTACTID_IN
            UNION
            SELECT '1', rc_bios__salutation_line_3__c
              FROM rc_bios__salutation__C
             WHERE rc_bios__contact__c = @CONTACTID_IN
               AND RC_BIOS__SALUTATION_TYPE__c = @SALUTATION_TYPE_IN) Q
			   order by q.ordernumber
     RETURN @SAL_LINE_3;
    END;
GO
