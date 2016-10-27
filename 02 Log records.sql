/************************************************************
*   All scripts contained within are Copyright � 2015 of    *
*   SQLCloud Limited, whether they are derived or actual    *
*   works of SQLCloud Limited or its representatives        *
*************************************************************
*   All rights reserved. No part of this work may be        *
*   reproduced or transmitted in any form or by any means,  *
*   electronic or mechanical, including photocopying,       *
*   recording, or by any information storage or retrieval   *
*   system, without the prior written permission of the     *
*   copyright owner and the publisher.                      *
************************************************************/
 
 --insert 151 cities ondisk table
USE Lockless_In_Seattle
GO
EXEC  usp_PopulateCities



-- you will see that SQL Server logged 151 log records
USE Lockless_In_Seattle
GO
SELECT  *
FROM    sys.fn_dblog(NULL, NULL)
WHERE   PartitionId IN ( SELECT partition_id
                         FROM   sys.partitions
                         WHERE  object_id = OBJECT_ID('Cities') )
ORDER BY [Current LSN] ASC;
GO



--insert 151 cities in-memory table
USE Lockless_In_Seattle
GO
EXEC  usp_PopulateCitiesIM 



-- you will see that SQL Server logged 151 log records
-- look at the log and return topmost In-Memory OLTP transaction
DECLARE @TransactionID NVARCHAR(14)
DECLARE @CurrentLSN NVARCHAR(23)

SELECT TOP 1 @TransactionID =
        [Transaction ID], @CurrentLSN = [Current LSN]
FROM    sys.fn_dblog(NULL, NULL)
WHERE   Operation = 'LOP_HK'
ORDER BY [Current LSN] DESC;

SELECT  *
FROM    sys.fn_dblog(NULL, NULL)
WHERE   [Transaction ID] = @TransactionID;

/*Listing 6-5: Break apart a LOP_HK log record.*/
SELECT  [Current LSN] ,
        [Transaction ID] ,
        Operation ,
        operation_desc ,
        tx_end_timestamp ,
        total_size ,
        OBJECT_NAME(table_id) AS TableName
FROM    sys.fn_dblog_xtp(NULL, NULL)
WHERE   [Current LSN] = @CurrentLSN;
GO
