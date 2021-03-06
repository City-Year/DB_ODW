USE [ODW]
GO
/****** Object:  StoredProcedure [dbo].[sp_refresh_DW_OLD]    Script Date: 12/1/2016 9:20:14 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_refresh_DW_OLD] 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	truncate table ODW.dbo.DimAccount

	insert into ODW.dbo.DimAccount(ID, Name)
	select ID, Name from ODW.dbo.Account

	drop table ODW.dbo.Credit_Account

	select *
	into ODW.dbo.Credit_Account
	from ODW.dbo.Account

	truncate table ODW.dbo.FactOpportunity

	insert into ODW.dbo.FactOpportunity(OppID, AccountID, HardAllocationKey, SoftCreditKey, OppAccountID, OppCampaignID, Hard, Soft, FY_Hard, FY_Soft)
	select a.ID, DimAccount.AccountID, [rC_Giving__Opportunity_Allocation__c].[rC_Giving__Opportunity__c] as HardAllocationKey,
	b.rC_Giving__Account__c as SoftCreditKey,
	a.AccountId, CampaignId CampaignID,
	[rC_Giving__Opportunity_Allocation__c].[Giving_Amount__c] as Hard,
	b.[rC_Giving__Amount__c] as Soft,
	[rC_Giving__Opportunity_Allocation__c].Fiscal_Year__c FY_Hard,
	a.Fiscal_Year__c FY_Soft
	from ODW.dbo.[rC_Giving__Opportunity_Allocation__c]	(nolock)
		inner join (select distinct ID, AccountID, CampaignId, Fiscal_Year__c from ODW.dbo.Opportunity (nolock)) a ON
			ODW.dbo.[rC_Giving__Opportunity_Allocation__c].[rC_Giving__Opportunity__c] = a.Id
		left outer join (select distinct rC_Giving__Account__c, sum(rc_Giving__Amount__c) as rc_Giving__Amount__c from ODW.dbo.rC_Giving__Opportunity_Credit__c group by rC_Giving__Account__c) b on
			a.AccountID = b.rC_Giving__Account__c
		inner join ODW.dbo.Account (nolock) on
			a.AccountId = Account.Id
		left outer join (select distinct AccountID from ODW.dbo.Contact (nolock)) c on
			Account.Id = c.AccountId
		inner join ODW.dbo.DimAccount (nolock) on
			Account.ID = DimAccount.ID

END

GO
