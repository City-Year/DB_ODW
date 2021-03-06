USE [ODW]
GO
/****** Object:  UserDefinedFunction [dbo].[SALUTATION_INSIDE_CONTACT_FIRSTNAME]    Script Date: 12/1/2016 9:20:14 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[SALUTATION_INSIDE_CONTACT_FIRSTNAME](@CONTACTID_IN varchar(18), @SALUTATION_TYPE_IN VARCHAR(255)) 
RETURNS varchar(255)
BEGIN
     DECLARE @SAL_LINE_1 VARCHAR(255);
          SELECT TOP 1 @SAL_LINE_1 = q.inside_salutation
          FROM
          (
          SELECT '2' ordernumber, replace(
                    CASE
                       WHEN A.FIRSTNAME IS NOT NULL
                       THEN
                          A.FIRSTNAME
                       ELSE
                          concat(a.SALUTATION, ' ', a.LASTNAME)
                    END,
                    ',',
                    ' ') inside_salutation
            FROM contact a
           WHERE ID = @CONTACTID_IN
          UNION
          SELECT '1', replace(rc_bios__inside_salutation__c,',',' ') inside_salutation
            FROM rc_bios__salutation__C
           WHERE rc_bios__contact__C = @CONTACTID_IN
             AND RC_BIOS__SALUTATION_TYPE__c = @SALUTATION_TYPE_IN) q
           ORDER BY ordernumber;
     RETURN @SAL_LINE_1;
    END;

GO
