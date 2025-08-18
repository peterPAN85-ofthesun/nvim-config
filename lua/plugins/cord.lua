return {
	'vyfor/cord.nvim',
	build = ':Cord update',
	-- opts = {}
	opts = function()
		return {
			text = {
				workspace = function(opts)
					local hour = tonumber(os.date('%H'))
					local status =
							hour >= 22 and '🌙 Late night coding' or
							hour >= 18 and '🌆 Evening session' or
							hour >= 12 and '☀️ Afternoon coding' or
							hour >= 5 and '🌅 Morning productivity' or
							'🌙 Midnight hacking'

					return string.format('%s: %s', status, opts.filename)
				end
			}
		}
	end
}
