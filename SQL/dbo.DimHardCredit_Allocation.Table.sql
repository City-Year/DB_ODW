USE [ODW]
GO
/****** Object:  Table [dbo].[DimHardCredit_Allocation]    Script Date: 12/1/2016 9:20:14 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DimHardCredit_Allocation](
	[HardCreditID] [int] IDENTITY(1,1) NOT NULL,
	[Received Connection ID] [varchar](18) NULL,
	[Sent Connection ID] [varchar](18) NULL,
	[Created By ID] [varchar](18) NULL,
	[Created Date] [datetime] NULL,
	[External ID] [varchar](255) NULL,
	[FFR Key] [varchar](255) NULL,
	[Fiscal Year] [varchar](255) NULL,
	[General Accounting Unit Name] [varchar](255) NULL,
	[Giving Amount] [decimal](18, 2) NULL,
	[Record ID] [varchar](18) NULL,
	[Deleted] [int] NULL,
	[Last Modified By ID] [varchar](18) NULL,
	[Last Modified Date] [datetime] NULL,
	[Location] [varchar](255) NULL,
	[Reference #] [varchar](80) NULL,
	[Opportunity: Probability] [decimal](18, 2) NULL,
	[Project] [varchar](18) NULL,
	[Proposal Amount] [decimal](18, 2) NULL,
	[Amount] [decimal](18, 2) NULL,
	[Archive?] [int] NULL,
	[Comments] [varchar](255) NULL,
	[Distribution %] [decimal](5, 2) NULL,
	[General Accounting Unit] [varchar](18) NULL,
	[Fixed?] [int] NULL,
	[Opportunity] [varchar](18) NULL,
	[Opportunity: Close Date] [datetime] NULL,
	[Opportunity: Current Giving Amount] [decimal](18, 2) NULL,
	[Opportunity: Stage] [varchar](255) NULL,
	[Revenue Category] [varchar](255) NULL,
	[Revenue Strategy] [varchar](255) NULL,
	[System Modstamp] [datetime] NULL,
	[Weighted Giving Amount] [decimal](18, 2) NULL,
	[Weighted Proposal Amount] [decimal](18, 2) NULL,
	[60% Weighted Proposal Amount] [decimal](18, 2) NULL,
	[90% Weighted Proposal Amount] [decimal](18, 2) NULL,
 CONSTRAINT [PK_DimHardCredit_Allocation] PRIMARY KEY NONCLUSTERED 
(
	[HardCreditID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [INDEXES]

GO
