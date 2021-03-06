USE [ODW]
GO
/****** Object:  StoredProcedure [dbo].[sp_refresh_DW_3c_Devo_Definitions]    Script Date: 12/1/2016 9:20:14 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_refresh_DW_3c_Devo_Definitions]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	-- Giving (All)
	update ODW.dbo.FactDonor_Full set [Giving (All)] = 'No'
	update ODW.dbo.FactDonor_Full set [Giving (All)] = 'Yes' where [Giving?] = 1

	-- Received Gifts
	update ODW.dbo.FactDonor_Full set [Received Gift] = 'No'
	update ODW.dbo.FactDonor_Full set [Received Gift] = 'Yes' where [Giving?] = 1 and Stage in ('Completed', 'Partially Collected')

	-- Open Pledge
	update ODW.dbo.FactDonor_Full set [Open Pledge] = 'No'
	update ODW.dbo.FactDonor_Full set [Open Pledge] = 'Yes' from ODW.dbo.FactDonor_Full (nolock) a inner join DimHardCredit_Allocation (nolock) b on a.AllocationID = b.HardCreditID where [Giving?] = 1 and Stage not in ('Completed', 'Canceled') and cast(substring(b.[Fiscal Year], 3, 2) as integer) >= 13

	-- Payment
	update ODW.dbo.FactDonor_Full set Payment = 'No'
	update ODW.dbo.FactDonor_Full set Payment = 'Yes' where Stage in ('Completed') and [Giving Transaction?] = 1

	-- Future Payment
	update ODW.dbo.FactDonor_Full set [Future Payment] = 'No'
	update ODW.dbo.FactDonor_Full set [Future Payment] = 'Yes' where Stage in ('Open') and [Giving Transaction?] = 1

	-- Future FY Gifts
	update ODW.dbo.FactDonor_Full set [Future FY Gifts] = 'No'
	update ODW.dbo.FactDonor_Full set [Future FY Gifts] = 'Yes' from ODW.dbo.FactDonor_Full (nolock) a inner join DimHardCredit_Allocation (nolock) b on a.AllocationID = b.HardCreditID where [Giving?] = 1 and cast(substring(b.[Fiscal Year], 3, 2) as integer) >= 15

	-- Gifts w/Soft Credits
	update ODW.dbo.FactDonor_Full set [Gifts w/Soft Credits] = 'No'
	update ODW.dbo.FactDonor_Full set [Gifts w/Soft Credits] = 'Yes' where [Giving?] = 1 and Stage in ('Completed') and Soft is not null

	-- Completed Proposals (Closed)
	update ODW.dbo.FactDonor_Full set [Completed Proposals (Closed)] = 'No'
	update ODW.dbo.FactDonor_Full set [Completed Proposals (Closed)] = 'Yes' where Closed = 1 and Won = 1 and [Record Type ID] = '012U000000017QWIAY' 

	-- Proposals (Non-Closed)
	update ODW.dbo.FactDonor_Full set [Proposals (Not Closed)] = 'No'
	update ODW.dbo.FactDonor_Full set [Proposals (Not Closed)] = 'Yes' where Closed = 0 and [Record Type ID] = '012U000000017QWIAY' 

	-- Completed Grants (Closed)
	update ODW.dbo.FactDonor_Full set [Completed Grants (Closed)] = 'No'
	update ODW.dbo.FactDonor_Full set [Completed Grants (Closed)] = 'Yes' where Closed = 1 and Won = 1 and [Record Type ID] = '012U000000017QTIAY'

	-- Completed Grants (Non-Closed)
	update ODW.dbo.FactDonor_Full set [Grants (Not Closed)] = 'No'
	update ODW.dbo.FactDonor_Full set [Grants (Not Closed)] = 'Yes' where Closed = 0 and [Record Type ID] = '012U000000017QTIAY' 


	/*
	-- Board
	update ODW.dbo.FactDonor_Full set [Board] = 'No'
	update ODW.dbo.FactDonor_Full set [Board] = 'Yes' where 

	-- Non-Donor
	update ODW.dbo.FactDonor_Full set [Non-Donor] = 'No'
	update ODW.dbo.FactDonor_Full set [Non-Donor] = 'Yes' where 

	-- Exclude List (Mailing)
	update ODW.dbo.FactDonor_Full set [Exclude List (Mailing)] = 'No'
	update ODW.dbo.FactDonor_Full set [Exclude List (Mailing)] = 'Yes' where 

	-- Exlude List (E-Mailing)
	update ODW.dbo.FactDonor_Full set [Exclude List (E-Mailing)] = 'No'
	update ODW.dbo.FactDonor_Full set [Exclude List (E-Mailing)] = 'Yes' where 

	-- Exclude List (Phone)
	update ODW.dbo.FactDonor_Full set [Exclude List (Phone)] = 'No'
	update ODW.dbo.FactDonor_Full set [Exclude List (Phone)] = 'Yes' where 

	-- Exclude List (Mail Yearly) 
	update ODW.dbo.FactDonor_Full set [Exclude List (Mail Yearly)] = 'No'
	update ODW.dbo.FactDonor_Full set [Exclude List (Mail Yearly)] = 'Yes' where 
	*/

END

GO
