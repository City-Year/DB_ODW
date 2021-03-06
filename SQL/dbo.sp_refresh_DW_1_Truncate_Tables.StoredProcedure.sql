USE [ODW]
GO
/****** Object:  StoredProcedure [dbo].[sp_refresh_DW_1_Truncate_Tables]    Script Date: 12/1/2016 9:20:14 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_refresh_DW_1_Truncate_Tables]
AS
BEGIN

	truncate table ODW.dbo.DimBiosAddress
	truncate table ODW.dbo.DimHardCredit_Allocation
	truncate table ODW.dbo.DimSoftCredit
	truncate table ODW.dbo.DimRelationship
	truncate table ODW.dbo.DimAccount
	truncate table ODW.dbo.DimCreditAccount
	truncate table ODW.dbo.DimCampaign
	truncate table ODW.dbo.DimContact
	truncate table ODW.dbo.DimBiosAccountSalutation
	truncate table ODW.dbo.DimBiosAccountPreferences
	truncate table ODW.dbo.DimBiosContactPreferences
	truncate table ODW.dbo.DimBiosContactSalutation
	truncate table ODW.dbo.DimCampaignMember
	truncate table ODW.dbo.DimCampaignContact
	truncate table ODW.dbo.DimBiosAccountAddress
	truncate table ODW.dbo.DimBiosContactAddress
	truncate table ODW.dbo.DimContactRelationship
	truncate table ODW.dbo.DimAccountRelationship
	truncate table ODW.dbo.DimRJSMembership

END

GO
