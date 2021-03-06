USE [ODW]
GO
/****** Object:  StoredProcedure [dbo].[sp_refresh_DW_3b_Soft_Credits]    Script Date: 12/1/2016 9:20:14 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_refresh_DW_3b_Soft_Credits]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

/*
	select d.AccountID, c.[Fiscal Year], c.[General Accounting Unit Name] BusinessUnit, 
	0 Soft, sum(c.[Amount]) as Soft1, sum(a.Amount) as Soft2
	into #Soft1
	from ODW.dbo.DimSoftCredit (nolock) a
	inner join FactDonor_Full (nolock) b on a.Opportunity = b.[Opportunity ID]
	inner join DimHardCredit_Allocation (nolock) c on b.AllocationID = c.HardCreditID
	inner join DimAccount (nolock) d on a.Account = d.[Account ID]
	group by d.AccountID, c.[General Accounting Unit Name], c.[Fiscal Year]

	update #Soft1 set Soft = Soft1 where Soft1 < Soft2
	update #Soft1 set Soft = Soft2 where Soft1 >= Soft2
*/

    -- Insert statements for procedure here
	select d.AccountID, Account, c.[General Accounting Unit Name] BusinessUnit, 
	case c.[Fiscal Year] 
		when 'FY10' then 'FY10'
		when 'FY11' then 'FY11'
		when 'FY12' then 'FY12'
		when 'FY13' then 'FY13'
		when 'FY14' then 'FY14'
		when 'FY15' then 'FY15'
	else 'Other' end [FiscalYear], 
	0 as Soft, sum(c.[Amount]) as Soft1, sum(a.Amount) as Soft2
	into #SoftCredit_Final
	from ODW.dbo.DimSoftCredit (nolock) a
	inner join FactDonor_Full (nolock) b on a.Opportunity = b.[Opportunity ID]
	inner join DimHardCredit_Allocation (nolock) c on b.AllocationID = c.HardCreditID
	inner join DimAccount (nolock) d on a.Account = d.[Account ID]
	inner join DimCampaign (nolock) e on b.OppCampaignID = e.[Campaign ID]
	where e.Name not in ('Voices Grants FY15','Voices Membership Dues FY14 and prior','Voices Membership Dues FY15')
	and b.Stage not in ('Canceled','Suspended','Uncollectible')
	group by d.AccountID, Account, c.[General Accounting Unit Name], 
	case c.[Fiscal Year] 
		when 'FY10' then 'FY10'
		when 'FY11' then 'FY11'
		when 'FY12' then 'FY12'
		when 'FY13' then 'FY13'
		when 'FY14' then 'FY14'
		when 'FY15' then 'FY15'
	else 'Other' end

	update #SoftCredit_Final set Soft = Soft1 where Soft1 < Soft2
	update #SoftCredit_Final set Soft = Soft2 where Soft1 >= Soft2
		
	update ODW.dbo.DimAccount set [Soft (FY10)] = 0, [Soft (FY11)] = 0, [Soft (FY12)] = 0, [Soft (FY13)] = 0, [Soft (FY14)] = 0, [Soft (FY15)] = 0

	update ODW.dbo.DimAccount set [Soft (FY10)] = isnull(Soft, 0) 
	from ODW.dbo.DimAccount (nolock) a 
	inner join (select FiscalYear, Account, sum(Soft) as Soft from #SoftCredit_Final (nolock) group by FiscalYear, Account) b on a.[Account ID] = b.Account
	where b.FiscalYear = 'FY10'

	update ODW.dbo.DimAccount set [Soft (FY11)] = isnull(Soft, 0) 
	from ODW.dbo.DimAccount (nolock) a 
	inner join (select FiscalYear, Account, sum(Soft) as Soft from #SoftCredit_Final (nolock) group by FiscalYear, Account) b on a.[Account ID] = b.Account
	where b.FiscalYear = 'FY11'

	update ODW.dbo.DimAccount set [Soft (FY12)] = isnull(Soft, 0) 
	from ODW.dbo.DimAccount (nolock) a 
	inner join (select FiscalYear, Account, sum(Soft) as Soft from #SoftCredit_Final (nolock) group by FiscalYear, Account) b on a.[Account ID] = b.Account
	where b.FiscalYear = 'FY12'

	update ODW.dbo.DimAccount set [Soft (FY13)] = isnull(Soft, 0) 
	from ODW.dbo.DimAccount (nolock) a 
	inner join (select FiscalYear, Account, sum(Soft) as Soft from #SoftCredit_Final (nolock) group by FiscalYear, Account) b on a.[Account ID] = b.Account
	where b.FiscalYear = 'FY13'

	update ODW.dbo.DimAccount set [Soft (FY14)] = isnull(Soft, 0) 
	from ODW.dbo.DimAccount (nolock) a 
	inner join (select FiscalYear, Account, sum(Soft) as Soft from #SoftCredit_Final (nolock) group by FiscalYear, Account) b on a.[Account ID] = b.Account
	where b.FiscalYear = 'FY14'

	update ODW.dbo.DimAccount set [Soft (FY15)] = isnull(Soft, 0) 
	from ODW.dbo.DimAccount (nolock) a 
	inner join (select FiscalYear, Account, sum(Soft) as Soft from #SoftCredit_Final (nolock) group by FiscalYear, Account) b on a.[Account ID] = b.Account
	where b.FiscalYear = 'FY15'

	select d.AccountID, Account, c.[General Accounting Unit Name] BusinessUnit, 
	case c.[Fiscal Year] 
		when 'FY05' then 'FY05'
		when 'FY06' then 'FY06'
		when 'FY07' then 'FY07'
		when 'FY08' then 'FY08'
		when 'FY09' then 'FY09'
		when 'FY10' then 'FY10'
		when 'FY11' then 'FY11'
		when 'FY12' then 'FY12'
		when 'FY13' then 'FY13'
		when 'FY14' then 'FY14'
		when 'FY15' then 'FY15'
	else 'Other' end [Fiscal Year], 
	0 as Soft, sum(c.[Amount]) as Soft1, sum(a.Amount) as Soft2
	into #SoftCredits_Recent
	from ODW.dbo.DimSoftCredit (nolock) a
	inner join FactDonor_Full (nolock) b on a.Opportunity = b.[Opportunity ID]
	inner join DimHardCredit_Allocation (nolock) c on b.AllocationID = c.HardCreditID
	inner join DimAccount (nolock) d on a.Account = d.[Account ID]
	inner join DimCampaign (nolock) e on b.OppCampaignID = e.[Campaign ID]
	where e.Name not in ('Voices Grants FY15','Voices Membership Dues FY14 and prior','Voices Membership Dues FY15')
	and b.Stage not in ('Canceled','Suspended','Uncollectible')
	group by d.AccountID, Account, c.[General Accounting Unit Name], 
	case c.[Fiscal Year] 
		when 'FY05' then 'FY05'
		when 'FY06' then 'FY06'
		when 'FY07' then 'FY07'
		when 'FY08' then 'FY08'
		when 'FY09' then 'FY09'
		when 'FY10' then 'FY10'
		when 'FY11' then 'FY11'
		when 'FY12' then 'FY12'
		when 'FY13' then 'FY13'
		when 'FY14' then 'FY14'
		when 'FY15' then 'FY15'
	else 'Other' end
	order by [Fiscal Year]

	update #SoftCredits_Recent set Soft = Soft1 where Soft1 < Soft2
	update #SoftCredits_Recent set Soft = Soft2 where Soft1 >= Soft2

	update ODW.dbo.DimAccountRecentHistory
	set [BR_SC] = b.Soft
	from ODW.dbo.DimAccountRecentHistory a inner join #SoftCredits_Recent b on a.AccountID = b.AccountID 
	where b.[Fiscal Year] = 'FY14' and b.[BusinessUnit] = 'Baton Rouge'

	update ODW.dbo.DimAccountRecentHistory
	set [BOS_SC_FY05] = b.Soft
	from ODW.dbo.DimAccountRecentHistory a inner join #SoftCredits_Recent b on a.AccountID = b.AccountID 
	where b.[Fiscal Year] = 'FY05' and b.[BusinessUnit] = 'Boston'

	update ODW.dbo.DimAccountRecentHistory
	set [BOS_SC_FY06] = b.Soft
	from ODW.dbo.DimAccountRecentHistory a inner join #SoftCredits_Recent b on a.AccountID = b.AccountID 
	where b.[Fiscal Year] = 'FY06' and b.[BusinessUnit] = 'Boston'

	update ODW.dbo.DimAccountRecentHistory
	set [BOS_SC_FY07] = b.Soft
	from ODW.dbo.DimAccountRecentHistory a inner join #SoftCredits_Recent b on a.AccountID = b.AccountID 
	where b.[Fiscal Year] = 'FY07' and b.[BusinessUnit] = 'Boston'

	update ODW.dbo.DimAccountRecentHistory
	set [BOS_SC_FY08] = b.Soft
	from ODW.dbo.DimAccountRecentHistory a inner join #SoftCredits_Recent b on a.AccountID = b.AccountID 
	where b.[Fiscal Year] = 'FY08' and b.[BusinessUnit] = 'Boston'

	update ODW.dbo.DimAccountRecentHistory
	set [BOS_SC_FY09] = b.Soft
	from ODW.dbo.DimAccountRecentHistory a inner join #SoftCredits_Recent b on a.AccountID = b.AccountID 
	where b.[Fiscal Year] = 'FY09' and b.[BusinessUnit] = 'Boston'

	update ODW.dbo.DimAccountRecentHistory
	set [BOS_SC_FY10] = b.Soft
	from ODW.dbo.DimAccountRecentHistory a inner join #SoftCredits_Recent b on a.AccountID = b.AccountID 
	where b.[Fiscal Year] = 'FY10' and b.[BusinessUnit] = 'Boston'

	update ODW.dbo.DimAccountRecentHistory
	set [BOS_SC_FY11] = b.Soft
	from ODW.dbo.DimAccountRecentHistory a inner join #SoftCredits_Recent b on a.AccountID = b.AccountID 
	where b.[Fiscal Year] = 'FY11' and b.[BusinessUnit] = 'Boston'

	update ODW.dbo.DimAccountRecentHistory
	set [BOS_SC_FY12] = b.Soft
	from ODW.dbo.DimAccountRecentHistory a inner join #SoftCredits_Recent b on a.AccountID = b.AccountID 
	where b.[Fiscal Year] = 'FY12' and b.[BusinessUnit] = 'Boston'

	update ODW.dbo.DimAccountRecentHistory
	set [BOS_SC_FY13] = b.Soft
	from ODW.dbo.DimAccountRecentHistory a inner join #SoftCredits_Recent b on a.AccountID = b.AccountID 
	where b.[Fiscal Year] = 'FY13' and b.[BusinessUnit] = 'Boston'
	
	update ODW.dbo.DimAccountRecentHistory
	set [BOS_SC] = b.Soft
	from ODW.dbo.DimAccountRecentHistory a inner join #SoftCredits_Recent b on a.AccountID = b.AccountID 
	where b.[Fiscal Year] = 'FY14' and b.[BusinessUnit] = 'Boston'

	update ODW.dbo.DimAccountRecentHistory
	set [BOS_SC_FY15] = b.Soft
	from ODW.dbo.DimAccountRecentHistory a inner join #SoftCredits_Recent b on a.AccountID = b.AccountID 
	where b.[Fiscal Year] = 'FY15' and b.[BusinessUnit] = 'Boston'

	update ODW.dbo.DimAccountRecentHistory
	set [CF_SC] = b.Soft
	from ODW.dbo.DimAccountRecentHistory a inner join #SoftCredits_Recent b on a.AccountID = b.AccountID 
	where b.[Fiscal Year] = 'FY14' and b.[BusinessUnit] = 'CareForce'

	update ODW.dbo.DimAccountRecentHistory
	set [CHI_SC] = b.Soft
	from ODW.dbo.DimAccountRecentHistory a inner join #SoftCredits_Recent b on a.AccountID = b.AccountID 
	where b.[Fiscal Year] = 'FY14' and b.[BusinessUnit] = 'Chicago'

	update ODW.dbo.DimAccountRecentHistory
	set [CLE_SC] = b.Soft
	from ODW.dbo.DimAccountRecentHistory a inner join #SoftCredits_Recent b on a.AccountID = b.AccountID 
	where b.[Fiscal Year] = 'FY14' and b.[BusinessUnit] = 'Cleveland'

	update ODW.dbo.DimAccountRecentHistory
	set [CIA_SC] = b.Soft
	from ODW.dbo.DimAccountRecentHistory a inner join #SoftCredits_Recent b on a.AccountID = b.AccountID 
	where b.[Fiscal Year] = 'FY14' and b.[BusinessUnit] = 'Columbia'

	update ODW.dbo.DimAccountRecentHistory
	set [CUS_SC] = b.Soft
	from ODW.dbo.DimAccountRecentHistory a inner join #SoftCredits_Recent b on a.AccountID = b.AccountID 
	where b.[Fiscal Year] = 'FY14' and b.[BusinessUnit] = 'Columbus'

	update ODW.dbo.DimAccountRecentHistory
	set [DEN_SC] = b.Soft
	from ODW.dbo.DimAccountRecentHistory a inner join #SoftCredits_Recent b on a.AccountID = b.AccountID 
	where b.[Fiscal Year] = 'FY14' and b.[BusinessUnit] = 'Denver'

	update ODW.dbo.DimAccountRecentHistory
	set [DET_SC] = b.Soft
	from ODW.dbo.DimAccountRecentHistory a inner join #SoftCredits_Recent b on a.AccountID = b.AccountID 
	where b.[Fiscal Year] = 'FY14' and b.[BusinessUnit] = 'Detroit'

	update ODW.dbo.DimAccountRecentHistory
	set [HQ_SC] = b.Soft
	from ODW.dbo.DimAccountRecentHistory a inner join #SoftCredits_Recent b on a.AccountID = b.AccountID 
	where b.[Fiscal Year] = 'FY14' and b.[BusinessUnit] = 'Headquarters'

	update ODW.dbo.DimAccountRecentHistory
	set [JAX_SC] = b.Soft
	from ODW.dbo.DimAccountRecentHistory a inner join #SoftCredits_Recent b on a.AccountID = b.AccountID 
	where b.[Fiscal Year] = 'FY14' and b.[BusinessUnit] = 'Jacksonville'

	update ODW.dbo.DimAccountRecentHistory
	set [LR_SC] = b.Soft
	from ODW.dbo.DimAccountRecentHistory a inner join #SoftCredits_Recent b on a.AccountID = b.AccountID 
	where b.[Fiscal Year] = 'FY14' and b.[BusinessUnit] = 'Little Rock'

	update ODW.dbo.DimAccountRecentHistory
	set [LA_SC] = b.Soft
	from ODW.dbo.DimAccountRecentHistory a inner join #SoftCredits_Recent b on a.AccountID = b.AccountID 
	where b.[Fiscal Year] = 'FY14' and b.[BusinessUnit] = 'Los Angeles'

	update ODW.dbo.DimAccountRecentHistory
	set [LOU_SC] = b.Soft
	from ODW.dbo.DimAccountRecentHistory a inner join #SoftCredits_Recent b on a.AccountID = b.AccountID 
	where b.[Fiscal Year] = 'FY14' and b.[BusinessUnit] = 'Louisiana'

	update ODW.dbo.DimAccountRecentHistory
	set [MIA_SC] = b.Soft
	from ODW.dbo.DimAccountRecentHistory a inner join #SoftCredits_Recent b on a.AccountID = b.AccountID 
	where b.[Fiscal Year] = 'FY14' and b.[BusinessUnit] = 'Miami'

	update ODW.dbo.DimAccountRecentHistory
	set [MIL_SC] = b.Soft
	from ODW.dbo.DimAccountRecentHistory a inner join #SoftCredits_Recent b on a.AccountID = b.AccountID 
	where b.[Fiscal Year] = 'FY14' and b.[BusinessUnit] = 'Milwaukee'

	update ODW.dbo.DimAccountRecentHistory
	set [NH_SC] = b.Soft
	from ODW.dbo.DimAccountRecentHistory a inner join #SoftCredits_Recent b on a.AccountID = b.AccountID 
	where b.[Fiscal Year] = 'FY14' and b.[BusinessUnit] = 'New Hampshire'

	update ODW.dbo.DimAccountRecentHistory
	set [NO_SC] = b.Soft
	from ODW.dbo.DimAccountRecentHistory a inner join #SoftCredits_Recent b on a.AccountID = b.AccountID 
	where b.[Fiscal Year] = 'FY14' and b.[BusinessUnit] = 'New Orleans'

	update ODW.dbo.DimAccountRecentHistory
	set [NYC_SC] = b.Soft
	from ODW.dbo.DimAccountRecentHistory a inner join #SoftCredits_Recent b on a.AccountID = b.AccountID 
	where b.[Fiscal Year] = 'FY14' and b.[BusinessUnit] = 'New York City'

	update ODW.dbo.DimAccountRecentHistory
	set [ORL_SC] = b.Soft
	from ODW.dbo.DimAccountRecentHistory a inner join #SoftCredits_Recent b on a.AccountID = b.AccountID 
	where b.[Fiscal Year] = 'FY14' and b.[BusinessUnit] = 'Orlando'

	update ODW.dbo.DimAccountRecentHistory
	set [PHI_SC] = b.Soft
	from ODW.dbo.DimAccountRecentHistory a inner join #SoftCredits_Recent b on a.AccountID = b.AccountID 
	where b.[Fiscal Year] = 'FY14' and b.[BusinessUnit] = 'Philadelphia'

	update ODW.dbo.DimAccountRecentHistory
	set [RI_SC] = b.Soft
	from ODW.dbo.DimAccountRecentHistory a inner join #SoftCredits_Recent b on a.AccountID = b.AccountID 
	where b.[Fiscal Year] = 'FY14' and b.[BusinessUnit] = 'Rhode Island'

	update ODW.dbo.DimAccountRecentHistory
	set [SAC_SC] = b.Soft
	from ODW.dbo.DimAccountRecentHistory a inner join #SoftCredits_Recent b on a.AccountID = b.AccountID 
	where b.[Fiscal Year] = 'FY14' and b.[BusinessUnit] = 'Sacramento'

	update ODW.dbo.DimAccountRecentHistory
	set [SA_SC] = b.Soft
	from ODW.dbo.DimAccountRecentHistory a inner join #SoftCredits_Recent b on a.AccountID = b.AccountID 
	where b.[Fiscal Year] = 'FY14' and b.[BusinessUnit] = 'San Antonio'

	update ODW.dbo.DimAccountRecentHistory
	set [SJ_SC] = b.Soft
	from ODW.dbo.DimAccountRecentHistory a inner join #SoftCredits_Recent b on a.AccountID = b.AccountID 
	where b.[Fiscal Year] = 'FY14' and b.[BusinessUnit] = 'San Jose'

	update ODW.dbo.DimAccountRecentHistory
	set [SEA_SC] = b.Soft
	from ODW.dbo.DimAccountRecentHistory a inner join #SoftCredits_Recent b on a.AccountID = b.AccountID 
	where b.[Fiscal Year] = 'FY14' and b.[BusinessUnit] = 'Seattle'

	update ODW.dbo.DimAccountRecentHistory
	set [TUL_SC] = b.Soft
	from ODW.dbo.DimAccountRecentHistory a inner join #SoftCredits_Recent b on a.AccountID = b.AccountID 
	where b.[Fiscal Year] = 'FY14' and b.[BusinessUnit] = 'Tulsa'

	update ODW.dbo.DimAccountRecentHistory
	set [WASH_SC] = b.Soft
	from ODW.dbo.DimAccountRecentHistory a inner join #SoftCredits_Recent b on a.AccountID = b.AccountID 
	where b.[Fiscal Year] = 'FY14' and b.[BusinessUnit] = 'Washington DC'

	update ODW.dbo.DimAccountRecentHistory set BR_SC  = 0 where BR_SC  is null
	update ODW.dbo.DimAccountRecentHistory set BOS_SC  = 0 where BOS_SC  is null
	update ODW.dbo.DimAccountRecentHistory set BOS_SC_FY05  = 0 where BOS_SC_FY05  is null
	update ODW.dbo.DimAccountRecentHistory set BOS_SC_FY06  = 0 where BOS_SC_FY06  is null
	update ODW.dbo.DimAccountRecentHistory set BOS_SC_FY07  = 0 where BOS_SC_FY07  is null
	update ODW.dbo.DimAccountRecentHistory set BOS_SC_FY08  = 0 where BOS_SC_FY08  is null
	update ODW.dbo.DimAccountRecentHistory set BOS_SC_FY09  = 0 where BOS_SC_FY09  is null
	update ODW.dbo.DimAccountRecentHistory set BOS_SC_FY10  = 0 where BOS_SC_FY10  is null
	update ODW.dbo.DimAccountRecentHistory set BOS_SC_FY11  = 0 where BOS_SC_FY11  is null
	update ODW.dbo.DimAccountRecentHistory set BOS_SC_FY12  = 0 where BOS_SC_FY12  is null
	update ODW.dbo.DimAccountRecentHistory set BOS_SC_FY13  = 0 where BOS_SC_FY13  is null
	update ODW.dbo.DimAccountRecentHistory set BOS_SC_FY15  = 0 where BOS_SC_FY15  is null
	update ODW.dbo.DimAccountRecentHistory set CF_SC  = 0 where CF_SC  is null
	update ODW.dbo.DimAccountRecentHistory set CHI_SC  = 0 where CHI_SC  is null
	update ODW.dbo.DimAccountRecentHistory set CLE_SC  = 0 where CLE_SC  is null
	update ODW.dbo.DimAccountRecentHistory set CIA_SC  = 0 where CIA_SC  is null
	update ODW.dbo.DimAccountRecentHistory set CUS_SC  = 0 where CUS_SC  is null
	update ODW.dbo.DimAccountRecentHistory set DEN_SC  = 0 where DEN_SC  is null
	update ODW.dbo.DimAccountRecentHistory set DET_SC  = 0 where DET_SC  is null
	update ODW.dbo.DimAccountRecentHistory set HQ_SC  = 0 where HQ_SC  is null
	update ODW.dbo.DimAccountRecentHistory set JAX_SC  = 0 where JAX_SC  is null
	update ODW.dbo.DimAccountRecentHistory set LR_SC  = 0 where LR_SC  is null
	update ODW.dbo.DimAccountRecentHistory set LA_SC  = 0 where LA_SC  is null
	update ODW.dbo.DimAccountRecentHistory set LOU_SC  = 0 where LOU_SC  is null
	update ODW.dbo.DimAccountRecentHistory set MIA_SC  = 0 where MIA_SC  is null
	update ODW.dbo.DimAccountRecentHistory set MIL_SC  = 0 where MIL_SC  is null
	update ODW.dbo.DimAccountRecentHistory set NH_SC  = 0 where NH_SC  is null
	update ODW.dbo.DimAccountRecentHistory set NO_SC  = 0 where NO_SC  is null
	update ODW.dbo.DimAccountRecentHistory set NYC_SC  = 0 where NYC_SC  is null
	update ODW.dbo.DimAccountRecentHistory set ORL_SC  = 0 where ORL_SC  is null
	update ODW.dbo.DimAccountRecentHistory set PHI_SC  = 0 where PHI_SC  is null
	update ODW.dbo.DimAccountRecentHistory set RI_SC  = 0 where RI_SC  is null
	update ODW.dbo.DimAccountRecentHistory set SAC_SC  = 0 where SAC_SC  is null
	update ODW.dbo.DimAccountRecentHistory set SA_SC  = 0 where SA_SC  is null
	update ODW.dbo.DimAccountRecentHistory set SJ_SC  = 0 where SJ_SC  is null
	update ODW.dbo.DimAccountRecentHistory set SEA_SC  = 0 where SEA_SC  is null
	update ODW.dbo.DimAccountRecentHistory set TUL_SC  = 0 where TUL_SC  is null
	update ODW.dbo.DimAccountRecentHistory set WASH_SC  = 0 where WASH_SC  is null


	update ODW.dbo.DimAccount
	set [Total (FY10)] = isnull([Soft (FY10)], 0) + isnull([Hard (FY10)], 0)
	,[Total (FY11)] = isnull([Soft (FY11)], 0) + isnull([Hard (FY11)], 0)
	,[Total (FY12)] = isnull([Soft (FY12)], 0) + isnull([Hard (FY12)], 0)
	,[Total (FY13)] = isnull([Soft (FY13)], 0) + isnull([Hard (FY13)], 0)
	,[Total (FY14)] = isnull([Soft (FY14)], 0) + isnull([Hard (FY14)], 0)
	,[Total (FY15)] = isnull([Soft (FY15)], 0) + isnull([Hard (FY15)], 0)

	select OpportunityID, AccountID, FY_Hard, sum(Hard) Amount, max([Close Date]) CloseDate, b.Name
	into #HardCredits
	from FactDonor_Full (nolock) a
	inner join DimCampaign (nolock) b on a.[Campaign ID] = b.[Campaign ID]
	where Hard <> 0
	group by OpportunityID, AccountID, FY_Hard, b.Name
	order by AccountID

	select b.OpportunityID, d.AccountID, c.[Fiscal Year] [FY_Hard], 
	0 Amount, sum(c.[Amount]) as Amount1, sum(a.[Amount]) as Amount2,
	max(a.[Opportunity: Close Date]) CloseDate, e.Name
	into #SoftCredits
	from ODW.dbo.DimSoftCredit (nolock) a
	inner join FactDonor_Full (nolock) b on a.Opportunity = b.[Opportunity ID]
	inner join DimHardCredit_Allocation (nolock) c on b.AllocationID = c.HardCreditID
	inner join DimAccount (nolock) d on a.Account = d.[Account ID]
	inner join DimCampaign (nolock) e on b.OppCampaignID = e.[Campaign ID]
	where e.Name not in ('Voices Grants FY15','Voices Membership Dues FY14 and prior','Voices Membership Dues FY15')
	and b.Stage not in ('Canceled','Suspended','Uncollectible')
	group by b.OpportunityID, d.AccountID, c.[Fiscal Year], e.Name

	update #SoftCredits set Amount = Amount1 where Amount1 < Amount2
	update #SoftCredits set Amount = Amount2 where Amount1 >= Amount2

	select a.* 
	into #MaxGift6Years
	from 
	(select OpportunityID, AccountID, FY_Hard, Amount, CloseDate, Name from #HardCredits
	UNION ALL
	select OpportunityID, AccountID, FY_Hard, Amount, CloseDate, Name from #SoftCredits
	) a

	select AccountID, max(CloseDate) MaxDate, min(CloseDate) MinDate
	into #MaxCloseDate6yrs
	from #MaxGift6Years 
	group by AccountID

	alter table #MaxCloseDate6yrs add CampaignName varchar(250)

	update #MaxCloseDate6yrs 
	set CampaignName = b.Name
	from #MaxCloseDate6yrs a
	inner join #MaxGift6Years b on a.AccountID = b.AccountID

	select a.* 
	into #MaxGift3Years
	from 
	(select OpportunityID, AccountID, FY_Hard, Amount, CloseDate from #HardCredits where FY_Hard in ('FY12', 'FY13', 'FY14', 'FY15')
	UNION ALL
	select OpportunityID, AccountID, FY_Hard, Amount, CloseDate from #SoftCredits where FY_Hard in ('FY12', 'FY13', 'FY14', 'FY15')
	) a

	select AccountID, max(CloseDate) MaxDate
	into #MaxCloseDate3yrs
	from #MaxGift3Years 
	group by AccountID
	-- 21,230

	select a.AccountID, a.Amount
    into #LatestGiftAmount3yrs
	from (select distinct AccountID, sum(Amount) as Amount, CloseDate from #MaxGift3Years group by AccountID, CloseDate) a 
	inner join #MaxCloseDate3yrs b on a.CloseDate = b.MaxDate and a.AccountID = b.AccountID
	-- 21,230

	select a.AccountID, a.Amount
    into #OldestGiftAmount
	from (select distinct AccountID, sum(Amount) as Amount, CloseDate from #MaxGift6Years group by AccountID, CloseDate) a 
	inner join #MaxCloseDate6yrs b on a.CloseDate = b.MinDate and a.AccountID = b.AccountID

	
	select AccountID, max(Amount) Hard
	into #MaxHard3yrs
	from #MaxGift3Years 
	group by AccountID
	-- 21,230

	select a.AccountID, max(a.CloseDate) CloseDate
	into #DateOfMaxGift3yrs
	from (select distinct AccountID, CloseDate, Amount from #MaxGift3Years) a
	inner join #MaxHard3yrs b on a.Amount = b.Hard and a.AccountID = b.AccountID
	group by a.AccountID
	-- 21,230

	update ODW.dbo.DimAccount 
	set [Date of Largest Gift Last 3 Years] = b.CloseDate
	from ODW.dbo.DimAccount (nolock) a inner join #DateOfMaxGift3yrs (nolock) b on a.AccountID = b.AccountID

	update ODW.dbo.DimAccount 
	set [Largest Gift - 3 yrs] = b.Hard
	from ODW.dbo.DimAccount (nolock) a inner join #MaxHard3yrs (nolock) b on a.AccountID = b.AccountID
	
	update ODW.dbo.DimAccount 
	set [Amount of Last Gift] = b.Amount
	from ODW.dbo.DimAccount (nolock) a inner join #LatestGiftAmount3yrs (nolock) b on a.AccountID = b.AccountID

	
	update ODW.dbo.DimAccount 
	set [Amount of First Gift] = b.Amount
	from ODW.dbo.DimAccount (nolock) a inner join #OldestGiftAmount (nolock) b on a.AccountID = b.AccountID

	update ODW.dbo.DimAccount 
	set [Date Of Last Gift]  = b.MaxDate,
	    [Date Of First Gift] = b.MinDate,
		[CampaignOfLastGift] = b.CampaignName
	from ODW.dbo.DimAccount (nolock) a inner join #MaxCloseDate6yrs (nolock) b on a.AccountID = b.AccountID

	update DimAccount set DateOfLastGiftIndicator = 'No'
	update DimAccount set DateOfLastGiftIndicator = 'Yes' where [Date Of Last Gift] between cast('7/1/2013' as date) and cast('6/30/2014' as date)

	update ODW.dbo.DimAccountRecentHistory set Boston_Indicator = 'No'

	update ODW.dbo.DimAccountRecentHistory set Boston_Indicator = 'Yes' where BOS_HC <> 0 or BOS_SC <> 0
	
	update ODW.dbo.DimAccount set Boston_Indicator_FY10_FY13 = 'No'
	update ODW.dbo.DimAccount
	set Boston_Indicator_FY10_FY13 = 'Yes' 
	from ODW.dbo.DimAccount (nolock) a inner join ODW.dbo.DimAccountRecentHistory (nolock) b on a.AccountID = b.AccountID
	where BOS_HC_FY10 <> 0 or BOS_HC_FY11 <> 0 or BOS_HC_FY12 <> 0 or BOS_HC_FY13 <> 0 or BOS_SC_FY10 <> 0 or BOS_SC_FY11 <> 0 or BOS_SC_FY12 <> 0 or BOS_SC_FY13 <> 0 

	update ODW.dbo.DimAccount set Boston_2K_Indicator_FY05_FY09 = 'No'
	update ODW.dbo.DimAccount
	set Boston_2k_Indicator_FY05_FY09 = 'Yes' 
	from ODW.dbo.DimAccount (nolock) a inner join ODW.dbo.DimAccountRecentHistory (nolock) b on a.AccountID = b.AccountID
	where 
	((BOS_HC_FY06 + BOS_SC_FY06) > 1 or (BOS_HC_FY07 + BOS_SC_FY07) > 1 or (BOS_HC_FY08 + BOS_SC_FY08) > 1
	or (BOS_HC_FY09 + BOS_SC_FY09) > 1 or (BOS_HC_FY10 + BOS_SC_FY10) > 1) and [Date Of Last Gift] <= cast('6/30/2010' as date)

	update ODW.dbo.DimAccount set Boston_2K_Indicator_FY10_FY13 = 'No'
	update ODW.dbo.DimAccount
	set Boston_2k_Indicator_FY10_FY13 = 'Yes' 
	from ODW.dbo.DimAccount (nolock) a 
--	inner join ODW.dbo.DimAccountRecentHistory (nolock) b on a.AccountID = b.AccountID
	inner join ODW.Recent_History.DimRecentGivingFY10 (nolock) c on a.AccountID = c.AccountID
	inner join ODW.Recent_History.DimRecentGivingFY11 (nolock) d on a.AccountID = d.AccountID
	inner join ODW.Recent_History.DimRecentGivingFY12 (nolock) e on a.AccountID = e.AccountID
	inner join ODW.Recent_History.DimRecentGivingFY13 (nolock) f on a.AccountID = f.AccountID
	where 
	(
	 	(c.BOS_HC_FY10 + c.BOS_SC_FY10) between 1 and 2000 
	 or	(d.BOS_HC_FY11 + d.BOS_SC_FY11) between 1 and 2000 
	 or (e.BOS_HC_FY12 + e.BOS_SC_FY12) between 1 and 2000 
	 or (f.BOS_HC_FY13 + f.BOS_SC_FY13) between 1 and 2000
	) and [Date Of Last Gift] <= cast('6/30/2013' as date)

	update ODW.dbo.DimAccount set [Consecutive_Giving_BOS_FY10_FY14] = 'No'
	update ODW.dbo.DimAccount
	set [Consecutive_Giving_BOS_FY10_FY14] = 'Yes' 
	from ODW.dbo.DimAccount (nolock) a 
	inner join ODW.Recent_History.DimRecentGivingFY10 (nolock) c on a.AccountID = c.AccountID
	inner join ODW.Recent_History.DimRecentGivingFY11 (nolock) d on a.AccountID = d.AccountID
	inner join ODW.Recent_History.DimRecentGivingFY12 (nolock) e on a.AccountID = e.AccountID
	inner join ODW.Recent_History.DimRecentGivingFY13 (nolock) f on a.AccountID = f.AccountID
	inner join ODW.Recent_History.DimRecentGivingFY14 (nolock) g on a.AccountID = g.AccountID
	where 
	(
	     (c.BOS_HC_FY10 + c.BOS_SC_FY10) > 1 
	  or (d.BOS_HC_FY11 + d.BOS_SC_FY11) > 1 
	  or (e.BOS_HC_FY12 + e.BOS_SC_FY12) > 1 
	  or (f.BOS_HC_FY13 + f.BOS_SC_FY13) > 1 
	  or (g.BOS_HC_FY14 + g.BOS_SC_FY14) > 1 
	 ) 

	update ODW.dbo.DimAccount set Current_Donors_BOS = 'No'
	update ODW.dbo.DimAccount
	set Current_Donors_BOS = 'Yes' 
	from ODW.dbo.DimAccount (nolock) a 
--	inner join ODW.dbo.DimAccountRecentHistory (nolock) b on a.AccountID = b.AccountID
	inner join ODW.Recent_History.DimRecentGivingFY14 (nolock) c on a.AccountID = c.AccountID
	inner join ODW.Recent_History.DimRecentGivingFY15 (nolock) d on a.AccountID = d.AccountID
	where (c.BOS_HC_FY14 + c.BOS_SC_FY14) between 1 and 2000 
	   OR (d.BOS_HC_FY15 + d.BOS_SC_FY15) between 1 and 2000

	update ODW.dbo.DimAccount set FY14_1k_Donors = 'No'
	update ODW.dbo.DimAccount
	set FY14_1k_Donors = 'Yes' 
	from ODW.dbo.DimAccount (nolock) a inner join ODW.dbo.DimAccountRecentHistory (nolock) b on a.AccountID = b.AccountID
	where [Total (FY14)] >= 1000

	update ODW.dbo.DimAccount set [Between_1_and_2000] = 'No'
	update ODW.dbo.DimAccount set [Between_1_and_2000] = 'Yes' where [Total (FY14)] between 1 and 2000

	update ODW.dbo.DimAccount set [BOS_FY14_10k] = 'No'

	update ODW.dbo.DimAccount 
	set [BOS_FY14_10k] = 'Yes'
	from ODW.dbo.DimAccount (nolock) a 
	inner join ODW.dbo.DimAccountRecentHistory b on a.AccountID = b.AccountID
	where (BOS_HC + BOS_SC >= 10000)

	update ODW.dbo.DimAccount set [BOS_FY14_Gifts] = 'No'

	update ODW.dbo.DimAccount 
	set [BOS_FY14_Gifts] = 'Yes'
	from ODW.dbo.DimAccount (nolock) a 
	inner join ODW.dbo.DimAccountRecentHistory b on a.AccountID = b.AccountID
	where BOS_HC <> 0 or BOS_SC <>0

	update ODW.dbo.DimAccount set [BOS_LYBUNTS] = 'No'

	update ODW.dbo.DimAccount 
	set [BOS_LYBUNTS] = 'Yes'
	from ODW.dbo.DimAccount (nolock) a 
	inner join ODW.dbo.DimAccountRecentHistory b on a.AccountID = b.AccountID
	where (BOS_HC_FY13 <> 0 or BOS_SC_FY13 <> 0) and (BOS_HC = 0 and BOS_SC = 0)

	update ODW.dbo.DimAccount set [BOS_SYBUNTS_1] = 'No'

	update ODW.dbo.DimAccount 
	set [BOS_SYBUNTS_1] = 'Yes'
	from ODW.dbo.DimAccount (nolock) a 
	inner join ODW.dbo.DimAccountRecentHistory b on a.AccountID = b.AccountID
	where (BOS_HC_FY12 <> 0 or BOS_SC_FY12 <> 0) and BOS_HC_FY13 = 0 and BOS_SC_FY13 = 0 and BOS_HC = 0 and BOS_SC = 0

	update ODW.dbo.DimAccount set [BOS_SYBUNTS_2] = 'No'

	update ODW.dbo.DimAccount 
	set [BOS_SYBUNTS_2] = 'Yes'
	from ODW.dbo.DimAccount (nolock) a 
	inner join ODW.dbo.DimAccountRecentHistory b on a.AccountID = b.AccountID
	where (BOS_HC_FY11 <> 0 or BOS_SC_FY11 <> 0) and (BOS_HC_FY12 <> 0 or BOS_SC_FY12 <> 0) 
	and (BOS_HC_FY13 <> 0 and BOS_SC_FY13 <> 0) and (BOS_HC = 0 and BOS_SC = 0)

	select AccountID, sum(BR_HC_FY14 + BR_SC_FY14 + BOS_HC_FY14 + BOS_SC_FY14 + CF_HC_FY14 + CF_SC_FY14 + CHI_HC_FY14 + CHI_SC_FY14 + CLE_HC_FY14 + CLE_SC_FY14 + CIA_HC_FY14 + CIA_SC_FY14 + CUS_HC_FY14 + CUS_SC_FY14 + DEN_HC_FY14 + DEN_SC_FY14 + DET_HC_FY14 + DET_SC_FY14 + HQ_HC_FY14 + HQ_SC_FY14 + JAX_HC_FY14 + JAX_SC_FY14 + LR_HC_FY14 + LR_SC_FY14 + LA_HC_FY14 + LA_SC_FY14 + LOU_HC_FY14 + LOU_SC_FY14 + MIA_HC_FY14 + MIA_SC_FY14 + MIL_HC_FY14 + MIL_SC_FY14 + NH_HC_FY14 + NH_SC_FY14 + NO_HC_FY14 + NO_SC_FY14 + NYC_HC_FY14 + NYC_SC_FY14 + ORL_HC_FY14 + ORL_SC_FY14 + PHI_HC_FY14 + PHI_SC_FY14 + RI_HC_FY14 + RI_SC_FY14 + SAC_HC_FY14 + SAC_SC_FY14 + SA_HC_FY14 + SA_SC_FY14 + SJ_HC_FY14 + SJ_SC_FY14 + SEA_HC_FY14 + SEA_SC_FY14 + TUL_HC_FY14 + TUL_SC_FY14 + WASH_HC_FY14 + WASH_SC_FY14) FY14_Total
	into #FY14_Givings
	from Recent_History.DimRecentGivingFY14
	group by AccountID

	update ODW.dbo.DimAccount
	set [Total (FY14)] = b.FY14_Total
	from ODW.dbo.DimAccount (nolock) a
	inner join #FY14_Givings (nolock) b on a.AccountID = b.AccountID

	update ODW.dbo.DimAccount
	set FY14_Total_Gift_Range = 'N/A'

	update ODW.dbo.DimAccount
	set FY14_Total_Gift_Range = '$1K - 4,999'
	where FY14_1K_Donors = 'Yes' and [Total (FY14)] between 1000 and 4999.99

	update ODW.dbo.DimAccount
	set FY14_Total_Gift_Range = '$5K - 9,999'
	where FY14_1K_Donors = 'Yes' and [Total (FY14)] between 5000 and 9999.99

	update ODW.dbo.DimAccount
	set FY14_Total_Gift_Range = '$10K - 24,999'
	where FY14_1K_Donors = 'Yes' and [Total (FY14)] between 10000 and 24999.99

	update ODW.dbo.DimAccount
	set FY14_Total_Gift_Range = '$25K - 49,999'
	where FY14_1K_Donors = 'Yes' and [Total (FY14)] between 25000 and 49999.99

	update ODW.dbo.DimAccount
	set FY14_Total_Gift_Range = '$50K - 99,999'
	where FY14_1K_Donors = 'Yes' and [Total (FY14)] between 50000 and 99999.99

	update ODW.dbo.DimAccount
	set FY14_Total_Gift_Range = '$100K - 249,999'
	where FY14_1K_Donors = 'Yes' and [Total (FY14)] between 100000 and 249999.99

	update ODW.dbo.DimAccount
	set FY14_Total_Gift_Range = '$250K - 999,999'
	where FY14_1K_Donors = 'Yes' and [Total (FY14)] between 250000 and 999999.99

	update ODW.dbo.DimAccount
	set FY14_Total_Gift_Range = '$1m+'
	where FY14_1K_Donors = 'Yes' and [Total (FY14)] >= 1000000

	select d.AccountID, c.[Fiscal Year], c.[General Accounting Unit Name] BusinessUnit, 
	0 Soft, sum(c.[Amount]) as Soft1, sum(a.Amount) as Soft2
	into #S1
	from ODW.dbo.DimSoftCredit (nolock) a
	inner join FactDonor_Full (nolock) b on a.Opportunity = b.[Opportunity ID]
	inner join DimHardCredit_Allocation (nolock) c on b.AllocationID = c.HardCreditID
	inner join DimAccount (nolock) d on a.Account = d.[Account ID]
	group by d.AccountID, c.[General Accounting Unit Name], c.[Fiscal Year]

	update #S1 set Soft = Soft1 where Soft1 < Soft2
	update #S1 set Soft = Soft2 where Soft1 >= Soft2

	select distinct AccountID, BusinessUnit, [Fiscal Year]
	into #ALL_Credits
	from
	(select a.AccountID, FY_Hard [Fiscal Year], replace([CY Allocation Location String], 'City Year ', '') [BusinessUnit], 
	sum(Hard) Hard
	from FactDonor_Full (nolock) a
	inner join DimAccount (nolock) b on a.AccountID = b.AccountID
	where Hard > 0 
	group by a.AccountID, FY_Hard, replace([CY Allocation Location String], 'City Year ', '')
	UNION ALL
	select AccountID, [Fiscal Year], BusinessUnit, Soft 
	from #S1) a
	order by AccountID, BusinessUnit, [Fiscal Year]
	-- 103,837

	select a.AccountID, FY_Hard, replace([CY Allocation Location String], 'City Year ', '') [BusinessUnit], 
	sum(Hard) Hard
	into #Hard
	from FactDonor_Full (nolock) a
	inner join DimAccount (nolock) b on a.AccountID = b.AccountID
	where Hard > 0 
	group by a.AccountID, FY_Hard, replace([CY Allocation Location String], 'City Year ', '')
	-- 97,437

	select d.AccountID, c.[General Accounting Unit Name] BusinessUnit, 
	c.[Fiscal Year], 
	0 Soft, sum(c.[Amount]) as Soft1, sum(a.Amount) as Soft2
	into #Soft
	from ODW.dbo.DimSoftCredit (nolock) a
	inner join FactDonor_Full (nolock) b on a.Opportunity = b.[Opportunity ID]
	inner join DimHardCredit_Allocation (nolock) c on b.AllocationID = c.HardCreditID
	inner join DimAccount (nolock) d on a.Account = d.[Account ID]
	group by d.AccountID, c.[General Accounting Unit Name], c.[Fiscal Year]
	order by [Fiscal Year]
	-- 7,975
	
	update #Soft set Soft = Soft1 where Soft1 < Soft2
	update #Soft set Soft = Soft2 where Soft1 >= Soft2

	update ODW.dbo.DimCampaignMember
	set [Campaign Group 1 Name] = b.Name
	from ODW.dbo.DimCampaignMember (nolock) a
	left outer join ODW_Stage.dbo.rC_Event__Campaign_Group__c (nolock) b on a.[Campaign Group 1] = b.ID

	update ODW.dbo.DimCampaignMember
	set [Campaign Group 2 Name] = b.Name
	from ODW.dbo.DimCampaignMember (nolock) a
	left outer join ODW_Stage.dbo.rC_Event__Campaign_Group__c (nolock) b on a.[Campaign Group 2] = b.ID

	update ODW.dbo.DimCampaignMember
	set [Campaign Group 3 Name] = b.Name
	from ODW.dbo.DimCampaignMember (nolock) a
	left outer join ODW_Stage.dbo.rC_Event__Campaign_Group__c (nolock) b on a.[Campaign Group 3] = b.ID

	update ODW.dbo.DimCampaignMember
	set [Guest Of Name] = b.[Full Name]
	from ODW.dbo.DimCampaignMember (nolock) a
	left outer join ODW.dbo.DimContact (nolock) b on a.[Guest Of] = b.[Contact ID]

	update ODW.dbo.DimCampaignMember
	set [Representative Of Name] = b.[Account Name no Household]
	from ODW.dbo.DimCampaignMember (nolock) a
	left outer join ODW.dbo.DimAccount (nolock) b on a.[Representative of] = b.[Account ID]

	update ODW.dbo.DimCampaignContact 
	set [Account Name] = b.[Account Name no Household]
	from ODW.dbo.DimCampaignContact (nolock) a
	inner join ODW.dbo.DimAccount (nolock) b on a.[Account ID] = b.[Account ID]

	update ODW.dbo.DimCampaignContact 
	set [Account Type] = b.[Account Type]
	from ODW.dbo.DimCampaignContact (nolock) a
	inner join ODW.dbo.DimAccount (nolock) b on a.[Account ID] = b.[Account ID]

	update ODW.dbo.DimCampaignContact 
	set [AccountID] = b.[AccountID]
	from ODW.dbo.DimCampaignContact (nolock) a
	inner join ODW.dbo.DimAccount (nolock) b on a.[Account ID] = b.[Account ID]

	update ODW.dbo.DimCampaignContact 
	set [Preferred Mailing Address Value] = b.[Address Name]
	from ODW.dbo.DimCampaignContact (nolock) a
	left outer join DimBiosAddress (nolock) b on a.[Preferred Mailing Address] = b.[Record ID]

	update ODW.dbo.DimCampaignContact 
	set [Street] = b.[Street Address]
	from ODW.dbo.DimCampaignContact (nolock) a
	left outer join DimBiosAddress (nolock) b on a.[Preferred Mailing Address] = b.[Record ID]

	update ODW.dbo.DimCampaignContact 
	set [City] = b.[City]
	from ODW.dbo.DimCampaignContact (nolock) a
	left outer join DimBiosAddress (nolock) b on a.[Preferred Mailing Address] = b.[Record ID]

	update ODW.dbo.DimCampaignContact 
	set [State] = b.[State]
	from ODW.dbo.DimCampaignContact (nolock) a
	left outer join DimBiosAddress (nolock) b on a.[Preferred Mailing Address] = b.[Record ID]

	update ODW.dbo.DimCampaignContact 
	set [Zip] = b.[Postal Code]
	from ODW.dbo.DimCampaignContact (nolock) a
	left outer join DimBiosAddress (nolock) b on a.[Preferred Mailing Address] = b.[Record ID]


	update ODW.dbo.DimAccount set [Accounts_With_Preferred_Contact] = 'No'
	update ODW.dbo.DimAccount 
	set [Accounts_With_Preferred_Contact] = 'Yes'
	from ODW.dbo.DimAccount (nolock) a 
	inner join ODW.dbo.DimContact (nolock) b on a.[Account ID] = b.[Account ID]
	where [Preferred Contact?] = 1

	update ODW.dbo.DimCampaignMember
	set [Preferred Mailing Address Values] = b.[Preferred Mailing Address Value]
	from ODW.dbo.DimCampaignMember (nolock) a
	left outer join ODW.dbo.DimCampaignContact (nolock) b on a.[Contact ID] = b.[Contact ID]

	update ODW.dbo.DimCampaignMember
	set [Street] = b.[Street]
	from ODW.dbo.DimCampaignMember (nolock) a
	left outer join ODW.dbo.DimCampaignContact (nolock) b on a.[Contact ID] = b.[Contact ID]

	update ODW.dbo.DimCampaignMember
	set [City] = b.[City]
	from ODW.dbo.DimCampaignMember (nolock) a
	left outer join ODW.dbo.DimCampaignContact (nolock) b on a.[Contact ID] = b.[Contact ID]

	update ODW.dbo.DimCampaignMember
	set [State] = b.[State]
	from ODW.dbo.DimCampaignMember (nolock) a
	left outer join ODW.dbo.DimCampaignContact (nolock) b on a.[Contact ID] = b.[Contact ID]

	update ODW.dbo.DimCampaignMember
	set [Zip] = b.[Zip]
	from ODW.dbo.DimCampaignMember (nolock) a
	left outer join ODW.dbo.DimCampaignContact (nolock) b on a.[Contact ID] = b.[Contact ID]

	update ODW.dbo.DimCampaignContact set [Do Not Mail] = 'No'

	update ODW.dbo.DimCampaignContact 
	set [Do Not Mail] = case b.[Do Not Mail?] when 0 then 'No' else 'Yes' end
	from ODW.dbo.DimCampaignContact (nolock) a 
	inner join DimBiosContactAddress (nolock) b on a.[Contact ID] = b.Contact

	update ODW.dbo.DimCampaignContact 
	set [Account#] = b.[Account#]
	from ODW.dbo.DimCampaignContact (nolock) a 
	inner join ODW.dbo.DimAccount (nolock) b on a.[Account ID] = b.[Account ID]

	update ODW.dbo.DimAccount set GalaFilter = 'No'

	update ODW.dbo.DimAccount 
	set GalaFilter = 'Yes'
	from ODW.dbo.DimAccount (nolock) a
	inner join ODW.dbo.GalaList (nolock) b on a.[Account ID] = b.[Account ID]

	update ODW.dbo.DimAccount set BOS_FY16_RJS = 'No'

	update ODW.dbo.DimAccount 
	set BOS_FY16_RJS = 'Yes'
	from ODW.dbo.DimAccount (nolock) a
	inner join (select distinct [Account ID]
	from DimCampaignMember (nolock) a
	inner join DimCampaignContact (nolock) b on a.[Contact ID] = b.[Contact ID]
	where [Campaign ID] = '701U0000000tUXDIA2') b on a.[Account ID] = b.[Account ID]

	DROP INDEX [ContactID] ON ODW.[dbo].[DimContactRelationshipProcessed] WITH ( ONLINE = OFF )

	select distinct Contact 
	into #Contacts
	from
	(select distinct [Contact From] Contact
	from ODW.dbo.DimContactRelationship (nolock)
	where [Contact From] <> 'N/A'
	UNION
	select distinct [Contact To] Contact
	from ODW.dbo.DimContactRelationship (nolock)
	where [Contact To] <> 'N/A') a
	order by Contact

	create clustered index #idx on #ContactS(Contact)

	-- C to C
	select a.[Contact From], a.[Contact To], a.[Full Name From], a.[Full Name To], a.[Account Name no Household From], a.[Account Name no Household To], a.Category
	into #CtoC
	from ODW.dbo.DimContactRelationship (nolock) a
	inner join #Contacts (nolock) b on a.[Contact From] = b.Contact
	where [Full Name To] <> 'N/A' and [Full Name From] <> 'N/A'

	create clustered index #idx1 on #CtoC([Contact From])

	-- C to A
	select a.[Contact From], a.[Full Name From], a.[Full Name To], a.[Account Name no Household From], a.[Account Name no Household To], a.Category
	into #CtoA
	from ODW.dbo.DimContactRelationship (nolock) a
	inner join #Contacts (nolock) b on a.[Contact From] = b.Contact
	where [Full Name From] <> 'N/A' and [Account Name no Household To] <> 'N/A'

	create clustered index #idx1 on #CtoA([Contact From])

	-- A to C
	select a.[Contact From], a.[Contact To], a.[Full Name From], a.[Full Name To], a.[Account Name no Household From], a.[Account Name no Household To], a.Category
	into #AtoC
	from ODW.dbo.DimContactRelationship (nolock) a
	inner join #Contacts (nolock) b on a.[Contact From] = b.Contact
	where [Full Name To] <> 'N/A' and [Account Name no Household From] <> 'N/A'

	create clustered index #idx1 on #AtoC([Contact To])

	truncate table ODW.dbo.DimContactRelationshipProcessed

	DECLARE @Contact VARCHAR(50) -- database name  

	DECLARE db_cursor CURSOR FOR  
	SELECT contact
	FROM #Contacts

	OPEN db_cursor   
	FETCH NEXT FROM db_cursor INTO @contact

	WHILE @@FETCH_STATUS = 0   
	BEGIN   

		   -- C to C part 1
		   insert into ODW.dbo.DimContactRelationshipProcessed([Contact ID], [Contact From], [Contact To], Relationship)
		   select [Contact From], [Full Name From], [Full Name To], Category from #CtoC where [Contact From] = @Contact
		   -- C to C part 2
		   insert into ODW.dbo.DimContactRelationshipProcessed([Contact ID], [Contact From], [Contact To], Relationship)
		   select [Contact To], [Full Name To], [Full Name From], Category from #CtoC where [Contact To] = @Contact
		   -- C to A
		   insert into ODW.dbo.DimContactRelationshipProcessed([Contact ID], [Contact From], [Account To], Relationship)
		   select [Contact From], [Full Name From], [Account Name no Household To], Category from #CtoA where [Contact From] = @Contact
		   -- A to C
		   insert into ODW.dbo.DimContactRelationshipProcessed([Contact ID], [Contact From], [Account To], Relationship)
		   select [Contact To], [Full Name To], [Account Name no Household From], Category from #AtoC where [Contact To] = @Contact

		   FETCH NEXT FROM db_cursor INTO @contact
	END   

	CLOSE db_cursor   
	DEALLOCATE db_cursor

	insert into ODW.dbo.DimContactRelationshipProcessed([Contact ID], Relationship, RelationshipType)
	select distinct a.[Contact ID], 'N/A', 'N/A' 
	from ODW.dbo.DimContact (nolock) a
	left outer join ODW.dbo.DimContactRelationshipProcessed (nolock) b on a.[Contact ID] = b.[Contact ID] 
	where b.[Contact ID]  is null

	update ODW.dbo.DimContactRelationshipProcessed set [Contact From] = 'N/A' where [Contact From] is null
	update ODW.dbo.DimContactRelationshipProcessed set [Contact To] = 'N/A' where [Contact To] is null
	update ODW.dbo.DimContactRelationshipProcessed set [Account To] = 'N/A' where [Account To] is null


	update ODW.dbo.DimContactRelationshipProcessed set RelationshipType = 'N/A' 
	where [Contact From] = 'N/A' and [Contact To] = 'N/A' and [Account To] = 'N/A' and RelationshipType is null

	update ODW.dbo.DimContactRelationshipProcessed set RelationshipType = 'Contact to Contact' where [Account To] = 'N/A' and RelationshipType is null
	update ODW.dbo.DimContactRelationshipProcessed set RelationshipType = 'Account to Contact' where [Contact To] = 'N/A' and RelationshipType is null

	CREATE CLUSTERED INDEX [ContactID] ON ODW.[dbo].[DimContactRelationshipProcessed]
	(
		[Contact ID] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]

	update ODW.dbo.DimAccount set Boston_Indicator = 'No'

	update ODW.dbo.DimAccount 
	set Boston_Indicator = 'Yes' 
	from ODW.dbo.DimAccount (nolock) a
	inner join Recent_History.DimRecentGivingFY14 (nolock) b on a.AccountID = b.AccountID
	where BOS_HC_FY14 <> 0 or BOS_SC_FY14 <> 0

	UPDATE ODW.dbo.DimAccountGivingHistory set Region = 'East' WHERE [Site] = 'Baltimore'
	UPDATE ODW.dbo.DimAccountGivingHistory set Region = 'East' WHERE [Site] = 'Boston'
	UPDATE ODW.dbo.DimAccountGivingHistory set Region = 'East' WHERE [Site] = 'Manchester'
	UPDATE ODW.dbo.DimAccountGivingHistory set Region = 'East' WHERE [Site] = 'New York'
	UPDATE ODW.dbo.DimAccountGivingHistory set Region = 'East' WHERE [Site] = 'Philadelphia'
	UPDATE ODW.dbo.DimAccountGivingHistory set Region = 'East' WHERE [Site] = 'Providence'
	UPDATE ODW.dbo.DimAccountGivingHistory set Region = 'East' WHERE [Site] = 'Washington, DC'

	UPDATE ODW.dbo.DimAccountGivingHistory set Region = 'West' WHERE [Site] = 'Sacramento'
	UPDATE ODW.dbo.DimAccountGivingHistory set Region = 'West' WHERE [Site] = 'Los Angeles'
	UPDATE ODW.dbo.DimAccountGivingHistory set Region = 'West' WHERE [Site] = 'San Jose'
	UPDATE ODW.dbo.DimAccountGivingHistory set Region = 'West' WHERE [Site] = 'Seattle'
	UPDATE ODW.dbo.DimAccountGivingHistory set Region = 'West' WHERE [Site] = 'Phoenix'
	UPDATE ODW.dbo.DimAccountGivingHistory set Region = 'West' WHERE [Site] = 'Las Vegas'

	UPDATE ODW.dbo.DimAccountGivingHistory set Region = 'Central' WHERE [Site] = 'New Orleans'
	UPDATE ODW.dbo.DimAccountGivingHistory set Region = 'Central' WHERE [Site] = 'San Antonio'
	UPDATE ODW.dbo.DimAccountGivingHistory set Region = 'Central' WHERE [Site] = 'Tulsa'
	UPDATE ODW.dbo.DimAccountGivingHistory set Region = 'Central' WHERE [Site] = 'Dallas'
	UPDATE ODW.dbo.DimAccountGivingHistory set Region = 'Central' WHERE [Site] = 'Denver'
	UPDATE ODW.dbo.DimAccountGivingHistory set Region = 'Central' WHERE [Site] = 'Baton Rouge'
	UPDATE ODW.dbo.DimAccountGivingHistory set Region = 'Central' WHERE [Site] = 'Houston'

	UPDATE ODW.dbo.DimAccountGivingHistory set Region = 'South' WHERE [Site] = 'Jacksonville'
	UPDATE ODW.dbo.DimAccountGivingHistory set Region = 'South' WHERE [Site] = 'Miami'
	UPDATE ODW.dbo.DimAccountGivingHistory set Region = 'South' WHERE [Site] = 'Orlando'
	UPDATE ODW.dbo.DimAccountGivingHistory set Region = 'South' WHERE [Site] = 'Columbia'
	UPDATE ODW.dbo.DimAccountGivingHistory set Region = 'South' WHERE [Site] = 'Little Rock'
	UPDATE ODW.dbo.DimAccountGivingHistory set Region = 'South' WHERE [Site] = 'Memphis'
	UPDATE ODW.dbo.DimAccountGivingHistory set Region = 'South' WHERE [Site] = 'Atlanta'
	UPDATE ODW.dbo.DimAccountGivingHistory set Region = 'South' WHERE [Site] = 'Charlotte'

	UPDATE ODW.dbo.DimAccountGivingHistory set Region = 'Midwest' WHERE [Site] = 'Kansas City'
	UPDATE ODW.dbo.DimAccountGivingHistory set Region = 'Midwest' WHERE [Site] = 'Chicago'
	UPDATE ODW.dbo.DimAccountGivingHistory set Region = 'Midwest' WHERE [Site] = 'Cleveland'
	UPDATE ODW.dbo.DimAccountGivingHistory set Region = 'Midwest' WHERE [Site] = 'Columbus'
	UPDATE ODW.dbo.DimAccountGivingHistory set Region = 'Midwest' WHERE [Site] = 'Detroit'
	UPDATE ODW.dbo.DimAccountGivingHistory set Region = 'Midwest' WHERE [Site] = 'Milwaukee'

END


GO
