return {
	{
		"Kurama622/profile.nvim",
		config = function()
			local comp = require("profile.components")
			require("profile").setup({
				avatar_opts = {
					force_blank = false,
				},
				user = "Kurama622",
				git_contributions = {
					start_week = 1,
					end_week = 53,
					empty_char = " ",
					full_char = { "", "󰧞", "", "", "" },
					fake_contributions = nil,
				},
				hide = {
					statusline = true,
					tabline = true,
				},
				disable_keys = { "h", "j", "k", "<Left>", "<Right>", "<Up>", "<Down>", "<C-f>" },
				cursor_pos = { 17, 48 },
				format = function()
					local header = {
						[[                                                                       ]],
						[[                                                                       ]],
						[[                                                                       ]],
						[[                                                                       ]],
						[[                                                                       ]],
						[[                                                                       ]],
						[[                                                                     ]],
						[[       ████ ██████           █████      ██                     ]],
						[[      ███████████             █████                             ]],
						[[      █████████ ███████████████████ ███   ███████████   ]],
						[[     █████████  ███    █████████████ █████ ██████████████   ]],
						[[    █████████ ██████████ █████████ █████ █████ ████ █████   ]],
						[[  ███████████ ███    ███ █████████ █████ █████ ████ █████  ]],
						[[ ██████  █████████████████████ ████ █████ █████ ████ ██████ ]],
						[[                                                                       ]],
					}
					for _, line in ipairs(header) do
						comp:text_component_render({ comp:text_component(line, "center", "ProfileBlue") })
					end

					comp:text_component_render({
						comp:text_component("git@github.com:Kurama622/profile.nvim", "center", "ProfileRed"),
						comp:text_component("──── By Kurama622", "right", "ProfileBlue"),
					})
					comp:separator_render()
					comp:card_component_render({
						type = "table",
						content = function()
							return {
								{
									title = "kurama622/llm.nvim",
									description = [[LLM Neovim Plugin: Effortless Natural
Language Generation with LLM's API]],
								},
								{
									title = "kurama622/profile.nvim",
									description = [[A Neovim plugin: Your Personal Homepage]],
								},
							}
						end,
						hl = {
							border = "ProfileYellow",
							text = "ProfileYellow",
						},
					})
					comp:separator_render()
					comp:git_contributions_render("ProfileGreen")
				end,
			})
			vim.api.nvim_set_keymap("n", "<leader>p", "<cmd>Profile<cr>", { silent = true })

			local user_mappings = {
				n = {
					["r"] = "<cmd>FzfLua oldfiles<cr>",
					["f"] = "<cmd>FzfLua files<cr>",
					["c"] = "<cmd>FzfLua files cwd=$HOME/.config/nvim<cr>",
					["/"] = "<cmd>FzfLua live_grep<cr>",
					["n"] = "<cmd>enew<cr>",
					["l"] = "<cmd>Lazy<cr>",
				},
			}
			vim.api.nvim_create_autocmd("FileType", {
				pattern = "profile",
				callback = function()
					for mode, mapping in pairs(user_mappings) do
						for key, cmd in pairs(mapping) do
							vim.api.nvim_buf_set_keymap(0, mode, key, cmd, { noremap = true, silent = true })
						end
					end
				end,
			})
		end,
	},
}
