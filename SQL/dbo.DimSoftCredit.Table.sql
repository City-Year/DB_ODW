USE [ODW]
GO
/****** Object:  Table [dbo].[DimSoftCredit]    Script Date: 12/1/2016 9:20:14 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DimSoftCredit](
	[SoftCreditID] [int] IDENTITY(1,1) NOT NULL,
	[Received Connection ID] [varchar](18) NULL,
	[Sent Connection ID] [varchar](18) NULL,
	[Created By ID] [varchar](18) NULL,
	[Created Date] [datetime] NULL,
	[Record ID] [varchar](18) NULL,
	[Deleted] [int] NULL,
	[Last Modified By ID] [varchar](18) NULL,
	[Last Modified Date] [datetime] NULL,
	[Reference #] [varchar](80) NULL,
	[Account] [varchar](18) NULL,
	[Amount] [decimal](18, 2) NULL,
	[Archive?] [int] NULL,
	[Contact] [varchar](18) NULL,
	[Contact Role] [varchar](255) NULL,
	[Distribution %] [decimal](5, 2) NULL,
	[Fixed?] [int] NULL,
	[Opportunity] [varchar](18) NULL,
	[Opportunity: Close Date] [datetime] NULL,
	[Opportunity: Current Giving Amount] [decimal](18, 2) NULL,
	[Opportunity: Stage] [varchar](1300) NULL,
	[Related To] [varchar](1300) NULL,
	[Type] [varchar](255) NULL,
	[System Modstamp] [datetime] NULL,
 CONSTRAINT [PK_DimSoftCredit] PRIMARY KEY NONCLUSTERED 
(
	[SoftCreditID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [INDEXES]

GO
