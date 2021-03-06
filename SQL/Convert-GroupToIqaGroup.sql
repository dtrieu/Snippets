BEGIN TRY

    BEGIN TRAN

	DECLARE @GroupName VARCHAR(255)
	SET @GroupName = 'Executive Committee'

	 -- Get old group's GroupKey
    DECLARE @OldGroupKey AS UNIQUEIDENTIFIER
    SET @OldGroupKey = (SELECT GroupKey FROM GroupMain WHERE Name = @GroupName AND IsAutoGenerated = 0)
	
	-- Get new group's GroupKey
    DECLARE @NewGroupKey AS UNIQUEIDENTIFIER
    SET @NewGroupKey = (SELECT GroupKey FROM GroupMain WHERE Name = @GroupName AND IsAutoGenerated = 1)

	-- Disable constraints
	ALTER TABLE DynamicGroup NOCHECK CONSTRAINT FK_DynamicGroup_GroupMain
	ALTER TABLE AccessItem NOCHECK CONSTRAINT FK_AccessItem_GroupMain
	ALTER TABLE GroupMember NOCHECK CONSTRAINT FK_GroupMember_GroupMain

	-- Delete old group
	DELETE GroupMain WHERE GroupKey = @OldGroupKey
	
    -- Update the group key in related tables
	UPDATE DynamicGroup SET GroupKey = @OldGroupKey WHERE GroupKey = @NewGroupKey
	UPDATE AccessItem SET GroupKey = @OldGroupKey WHERE GroupKey = @NewGroupKey
    
	-- Remove group members
	DELETE GroupMember WHERE GroupKey = @NewGroupKey
	DELETE GroupMember WHERE GroupKey = @OldGroupKey

	-- Replace IQA group's GroupKey with old group's GroupKey
	UPDATE GroupMain SET GroupKey = @OldGroupKey WHERE GroupKey = @NewGroupKey

	-- Enable constraints
	ALTER TABLE GroupMember WITH CHECK CHECK CONSTRAINT FK_GroupMember_GroupMain
	ALTER TABLE AccessItem WITH CHECK CHECK CONSTRAINT FK_AccessItem_GroupMain
	ALTER TABLE DynamicGroup WITH CHECK CHECK CONSTRAINT FK_DynamicGroup_GroupMain
                                
    COMMIT TRAN
	--ROLLBACK
                
END TRY
BEGIN CATCH
 
    ROLLBACK
    
    SELECT  
    ERROR_NUMBER() AS ErrorNumber  
    ,ERROR_SEVERITY() AS ErrorSeverity  
    ,ERROR_STATE() AS ErrorState  
    ,ERROR_PROCEDURE() AS ErrorProcedure  
    ,ERROR_LINE() AS ErrorLine  
    ,ERROR_MESSAGE() AS ErrorMessage;  
    
END CATCH
