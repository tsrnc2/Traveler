extends Control

func initialize(wallet_node: Node, metabolism_node : Node,stamina_node : Node, wanted_node :Node, PlayerOverview:Control) -> void:
	$MetabalisimBars.initialize(metabolism_node,stamina_node,PlayerOverview)
	$WantedLevelPanel/WantedLevel.initialize(wanted_node)
	$WalletHUD.initialize(wallet_node)
