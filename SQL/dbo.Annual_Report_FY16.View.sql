USE [ODW]
GO
/****** Object:  View [dbo].[Annual_Report_FY16]    Script Date: 12/1/2016 9:20:14 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[Annual_Report_FY16]
AS
SELECT     TOP (100) PERCENT b.TOTAL_FY16 AS FY16_Total, a.[Account Name no Household], a.[Account ID], a.Account#, a.[Account Type], a.Subtype, a.[Sort Key], 
                      c.[Salutation Type], c.[Salutation Line 1], a.[Billing Street], a.[Billing City], a.[Billing State/Province], a.[Billing Zip/Postal Code], a.Salutation, b.AccountID, 
                      b.BR_HC_FY16, b.BR_SC_FY16, b.BR_PandT_FY16, b.BOS_HC_FY16, b.BOS_SC_FY16, b.BOS_PandT_FY16, b.CF_HC_FY16, b.CF_SC_FY16, b.CF_PandT_FY16, 
                      b.CHI_HC_FY16, b.CHI_SC_FY16, b.CHI_PandT_FY16, b.CLE_HC_FY16, b.CLE_SC_FY16, b.CLE_PandT_FY16, b.CIA_HC_FY16, b.CIA_SC_FY16, b.CIA_PandT_FY16, 
                      b.CUS_HC_FY16, b.CUS_SC_FY16, b.CUS_PandT_FY16, b.DEN_HC_FY16, b.DEN_SC_FY16, b.DEN_PandT_FY16, b.DET_HC_FY16, b.DET_SC_FY16, 
                      b.DET_PandT_FY16, b.HQ_HC_FY16, b.HQ_SC_FY16, b.HQ_PandT_FY16, b.JAX_HC_FY16, b.JAX_SC_FY16, b.JAX_PandT_FY16, b.LR_HC_FY16, b.LR_SC_FY16, 
                      b.LR_PandT_FY16, b.LA_HC_FY16, b.LA_SC_FY16, b.LA_PandT_FY16, b.LOU_HC_FY16, b.LOU_SC_FY16, b.LOU_PandT_FY16, b.MIA_HC_FY16, b.MIA_SC_FY16, 
                      b.MIA_PandT_FY16, b.MIL_HC_FY16, b.MIL_SC_FY16, b.MIL_PandT_FY16, b.NH_HC_FY16, b.NH_SC_FY16, b.NH_PandT_FY16, b.NO_HC_FY16, b.NO_SC_FY16, 
                      b.NO_PandT_FY16, b.NYC_HC_FY16, b.NYC_SC_FY16, b.NYC_PandT_FY16, b.ORL_HC_FY16, b.ORL_SC_FY16, b.ORL_PandT_FY16, b.PHI_HC_FY16, 
                      b.PHI_SC_FY16, b.PHI_PandT_FY16, b.RI_HC_FY16, b.RI_SC_FY16, b.RI_PandT_FY16, b.SAC_HC_FY16, b.SAC_SC_FY16, b.SAC_PandT_FY16, b.SA_HC_FY16, 
                      b.SA_SC_FY16, b.SA_PandT_FY16, b.SJ_HC_FY16, b.SJ_SC_FY16, b.SJ_PandT_FY16, b.SEA_HC_FY16, b.SEA_SC_FY16, b.SEA_PandT_FY16, b.TUL_HC_FY16, 
                      b.TUL_SC_FY16, b.TUL_PandT_FY16, b.WASH_HC_FY16, b.WASH_SC_FY16, b.WASH_PandT_FY16, b.TOTAL_FY16, b.TOTAL_SOFT_FY16, b.TOTAL_HARD_FY16, 
                      b.TOTAL_FY16_with_PandT, b.GaveVia_FY16, b.DAL_HC_FY16, b.DAL_SC_FY16, b.DAL_PandT_FY16
FROM         dbo.DimAccount AS a WITH (nolock) INNER JOIN
                      Recent_History.DimRecentGivingFY16 AS b WITH (nolock) ON a.AccountID = b.AccountID LEFT OUTER JOIN
                      dbo.DimBiosAccountSalutation AS c WITH (nolock) ON a.[Account ID] = c.Account
WHERE     (a.[Account Type] NOT IN ('Governmental Agency', 'School/Higher Education')) AND (b.TOTAL_FY16 > 1000)
ORDER BY a.[Account Name no Household]

GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "a"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 114
               Right = 324
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "b"
            Begin Extent = 
               Top = 6
               Left = 362
               Bottom = 114
               Right = 566
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "c"
            Begin Extent = 
               Top = 6
               Left = 604
               Bottom = 114
               Right = 801
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'Annual_Report_FY16'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'Annual_Report_FY16'
GO
