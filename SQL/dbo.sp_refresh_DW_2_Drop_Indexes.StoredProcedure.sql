USE [ODW]
GO
/****** Object:  StoredProcedure [dbo].[sp_refresh_DW_2_Drop_Indexes]    Script Date: 12/1/2016 9:20:14 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_refresh_DW_2_Drop_Indexes]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DROP INDEX [AccountID] ON [dbo].[DimAccount]
	DROP INDEX [ID] ON [dbo].[DimAccount]
	DROP INDEX [Account] ON [dbo].[DimBiosAccountPreferences]
	DROP INDEX [Account] ON [dbo].[DimBiosAccountSalutation]
	DROP INDEX [BiosAddressID] ON [dbo].[DimBiosAddress]
	DROP INDEX [RecordID] ON [dbo].[DimBiosAddress]
	DROP INDEX [BiosSalutationID] ON [dbo].[DimBiosContactSalutation]
	DROP INDEX [RecordID] ON [dbo].[DimBiosContactSalutation]
	DROP INDEX [CampaignID] ON [dbo].[DimCampaign]
	DROP INDEX [CampaignIDNC] ON [dbo].[DimCampaign]
	DROP INDEX [CampaignID] ON [dbo].[DimCampaignMember]
	DROP INDEX [ContactID] ON [dbo].[DimCampaignMember]
	DROP INDEX [ContactID] ON [dbo].[DimCampaignContact]
	DROP INDEX [ContactID] ON [dbo].[DimContact]
	DROP INDEX [AccountID] ON [dbo].[DimContact]
	DROP INDEX [ContactID2] ON [dbo].[DimContact]
	DROP INDEX [PreferredMailingAddress] ON [dbo].[DimContact]
	DROP INDEX [Contact] ON [dbo].[DimBiosContactPreferences]
	DROP INDEX [Contact] ON [dbo].[DimBiosContactSalutation]
	DROP INDEX [HardCreditID] ON [dbo].[DimHardCredit_Allocation]
	DROP INDEX [OpportunityID] ON [dbo].[DimHardCredit_Allocation]
	DROP INDEX [RelationshipID] ON [dbo].[DimRelationship]
	DROP INDEX [SoftCreditID] ON [dbo].[DimSoftCredit]
	DROP INDEX [Account] ON [dbo].[DimSoftCredit]
	DROP INDEX [Account] ON [dbo].[DimCreditAccount]
	DROP INDEX [AccountID] ON [dbo].[FactDonor]
	DROP INDEX [AllocationID] ON [dbo].[FactDonor]
	DROP INDEX [OppAccountID] ON [dbo].[FactDonor]
	DROP INDEX [OppCampaignID] ON [dbo].[FactDonor]
	DROP INDEX [OppID] ON [dbo].[FactDonor]
	DROP INDEX [AccountID] ON [dbo].[FactDonor_Full]
	DROP INDEX [AllocationID] ON [dbo].[FactDonor_Full]
	DROP INDEX [OppAccountID] ON [dbo].[FactDonor_Full]
	DROP INDEX [OppCampaignID] ON [dbo].[FactDonor_Full]
	DROP INDEX [OppID] ON [dbo].[FactDonor_Full]
	DROP INDEX [Account] ON [dbo].[DimBiosAccountAddress]
	DROP INDEX [Contact] ON [dbo].[DimBiosContactAddress]
	DROP INDEX [ContactFrom] ON [dbo].[DimContactRelationship]
	DROP INDEX [ContactTo] ON [dbo].[DimContactRelationship]
	DROP INDEX [AccountFrom] ON [dbo].[DimAccountRelationship]
	DROP INDEX [AccountTo] ON [dbo].[DimAccountRelationship]
	DROP INDEX [AccountID] ON [Recent_History].[DimRecentGivingFY05] WITH ( ONLINE = OFF )
	DROP INDEX [AccountID] ON [Recent_History].[DimRecentGivingFY06] WITH ( ONLINE = OFF )
	DROP INDEX [AccountID] ON [Recent_History].[DimRecentGivingFY07] WITH ( ONLINE = OFF )
	DROP INDEX [AccountID] ON [Recent_History].[DimRecentGivingFY08] WITH ( ONLINE = OFF )
	DROP INDEX [AccountID] ON [Recent_History].[DimRecentGivingFY09] WITH ( ONLINE = OFF )
	DROP INDEX [AccountID] ON [Recent_History].[DimRecentGivingFY10] WITH ( ONLINE = OFF )
	DROP INDEX [AccountID] ON [Recent_History].[DimRecentGivingFY11] WITH ( ONLINE = OFF )
	DROP INDEX [AccountID] ON [Recent_History].[DimRecentGivingFY12] WITH ( ONLINE = OFF )
	DROP INDEX [AccountID] ON [Recent_History].[DimRecentGivingFY13] WITH ( ONLINE = OFF )
	DROP INDEX [AccountID] ON [Recent_History].[DimRecentGivingFY14] WITH ( ONLINE = OFF )
	DROP INDEX [AccountID] ON [Recent_History].[DimRecentGivingFY15] WITH ( ONLINE = OFF )
	DROP INDEX [AccountID] ON [Recent_History].[DimRecentGivingFY16] WITH ( ONLINE = OFF )
	DROP INDEX [AccountID] ON [Recent_History].[DimRecentGivingFY17] WITH ( ONLINE = OFF )
	DROP INDEX [AccountID] ON [Recent_History].[DimRecentGivingFY18] WITH ( ONLINE = OFF )
	DROP INDEX [AccountID] ON [Recent_History].[DimRecentGivingFY19] WITH ( ONLINE = OFF )
	DROP INDEX [AccountID] ON [Recent_History].[DimRecentGivingFY20] WITH ( ONLINE = OFF )
	DROP INDEX [AccountID] ON [Recent_History].[DimTotalGiving] WITH ( ONLINE = OFF )
	DROP INDEX [AccountID] ON [dbo].[DimAccountGivingHistory] WITH ( ONLINE = OFF )

END

GO
