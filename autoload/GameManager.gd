extends Node

var sanity = 100
var memory_shards = 0

func spend_sanity(amount: int) -> bool:
	if sanity >= amount:
		sanity -= amount
		return true
	return false
