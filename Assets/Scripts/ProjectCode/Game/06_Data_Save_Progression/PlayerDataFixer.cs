public static class PlayerDataFixer
{
	public static void FixSilkSpools(PlayerData playerData, SceneData sceneData)
	{
		int expectedSilkSpools;
		SceneData.PersistentItemDataCollection<bool, SceneData.SerializableBoolData> persistentBools;
		if (playerData != null && sceneData != null)
		{
			_ = playerData.silkMax;
			_ = playerData.silkSpoolParts;
			expectedSilkSpools = 0;
			persistentBools = sceneData.PersistentBools;
			CountInWorld("Bone_11b", "Silk Spool");
			CountInWorld("Bone_East_13", "Silk Spool");
			CountInWorld("Greymoor_02", "Silk Spool");
			CountInWorld("Song_19_entrance", "Silk Spool");
			CountInWorld("Under_10", "Silk Spool");
			CountInWorld("Ward_01", "Silk Spool");
			CountInWorld("Library_11b", "Silk Spool");
			CountInWorld("Cog_07", "Silk Spool");
			CountInWorld("Peak_01", "Silk Spool");
			CountInWorld("Dock_03c", "Silk Spool");
			CountInWorld("Arborium_09", "Silk Spool");
			CountInWorld("Weave_11", "Silk Spool");
			CountInWorld("Hang_03_top", "Silk Spool");
			CountShopPiece(playerData.purchasedGrindleSpoolPiece, "Grindle Shop Piece (Coral_42)");
			CountShopPiece(playerData.PurchasedBelltownSpoolSegment, "Belltown Shop Piece");
			CountShopPiece(playerData.MerchantEnclaveSpoolPiece, "Merchant Enclave Shop Piece (Song_Enclave)");
			CountShopPiece(playerData.MetCaravanTroupeLeaderJudge, "Flea Caravan Troupe Leader Judge Piece (Coral_Judge_Arena)");
			CountQuestPiece(playerData.QuestCompletionData.GetData("Save Sherma").IsCompleted, "Save Sherma Quest Piece (Ward_09)");
		}
		void CountInWorld(string scene, string key)
		{
			if (persistentBools.TryGetValue(scene, key, out var value) && value.Value)
			{
				expectedSilkSpools++;
			}
		}
		void CountQuestPiece(bool completed, string name)
		{
			if (completed)
			{
				expectedSilkSpools++;
			}
		}
		void CountShopPiece(bool hasPiece, string name)
		{
			if (hasPiece)
			{
				expectedSilkSpools++;
			}
		}
	}
}
