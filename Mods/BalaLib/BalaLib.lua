--- STEAMODDED HEADER
--- MOD_NAME: BalaLib
--- MOD_ID: balalib
--- MOD_AUTHOR: [Toeler]
--- MOD_DESCRIPTION: A core library providing common features to other mods. v1.0.0
--- PRIORITY: -10

----------------------------------------------
------------MOD CODE--------------------------

function SMODS.INIT.balalib()
	local TAG = 'BalaLib'

	local balalib_mod = SMODS.findModByID("balalib")
	local s_sprites = SMODS.Sprite:new("balalib_sprites", balalib_mod.path, "sprites.png", 32, 32, "asset_atli")
	s_sprites:register()

	local function get_lock_icon(ui_box, is_locked)
		if is_locked == nil then
			is_locked = not ui_box.states.drag.can
		end

		local _x = is_locked and 0 or 1
		local icon = Sprite(0, 0, 0.2, 0.2, G.ASSET_ATLAS["balalib_sprites"], { x = _x, y = 0 })
		icon.states.drag.can = false
		return icon
	end

	local function get_anchor_icon(ui_box, anchor)
		local x_index = {
			["Top Right"] = 3,
			["Right"] = 4,
			["Bottom Right"] = 5,
			["Bottom"] = 6,
			["Bottom Left"] = 7,
			["Left"] = 8,
			["Top Left"] = 9,
			["Top"] = 10
		}

		if anchor == nil then
			anchor = ui_box.states.anchor or x_index[1]
		end

		local _x = x_index[anchor]
		local icon = Sprite(0, 0, 0.2, 0.2, G.ASSET_ATLAS["balalib_sprites"], { x = _x, y = 0 })
		icon.states.drag.can = false
		return icon
	end

	function UIBox:remove_UIE_by_ID(id, node)
		if not node then node = self.UIRoot end

		if node.config and node.config.id == id then
			node:remove()
			return true
		end

		local childIndex = nil
		for k, v in pairs(node.children) do
			if v.config and v.config.id == id then
				childIndex = k
				break
			end
		end

		if childIndex then
			node.children[childIndex]:remove()
			table.remove(node.children, childIndex)
			return true
		else
			for k, v in pairs(node.children) do
				local removed = self:remove_UIE_by_ID(id, v)
				if removed then return true end
			end
		end

		return nil
	end

	MoveableContainer = UIBox:extend()
	function MoveableContainer:init(args)
		if args.config.locked == nil then
			args.config.locked = true
		end
		if args.config.anchor == nil then
			args.config.anchor = "Top Right"
		end

		local settings_icon = Sprite(0, 0, 0.2, 0.2, G.ASSET_ATLAS["balalib_sprites"], { x = 2, y = 0 })
		settings_icon.states.drag.can = false

		local function get_lock_tooltip()
			return {
				n = G.UIT.R,
				nodes = {
					{
						n = G.UIT.T,
						config = {
							text = 'Position: ' .. (self.states.drag.can and 'Unlocked' or 'Locked'),
							scale = 0.15,
							colour = G.C.UI.TEXT_DARK
						}
					},
				}
			}
		end

		local btn_lock = {
			n = G.UIT.C,
			config = {
				id = 'btn_lock',
				colour = { 1, 1, 1, 0.010001 },
				padding = 0.01,
				r = 0.1,
				hover = true,
				button = 'bl_toggle_moveablecontainer_lock',
				button_dist = 0,
				tooltip = { filler = { func = get_lock_tooltip } }
			},
			nodes = {
				{ n = G.UIT.O, config = { id = 'icon', object = get_lock_icon(self, args.config.locked) } }
			}
		}

		local function get_anchor_tooltip()
			return {
				n = G.UIT.R,
				nodes = {
					{
						n = G.UIT.R,
						nodes = {
							{
								n = G.UIT.T,
								config = {
									text = 'Anchor: ' .. tostring(self.states.anchor),
									scale = 0.15,
									colour = G.C.UI.TEXT_DARK
								}
							},
						}
					},
					{
						n = G.UIT.R,
						nodes = {
							{
								n = G.UIT.T,
								config = {
									text = 'Click to cycle window anchor point',
									scale = 0.15,
									colour = G.C.UI.TEXT_DARK
								}
							},
						}
					}
				}
			}
		end

		local btn_anchor = {
			n = G.UIT.C,
			config = {
				id = 'btn_anchor',
				colour = { 1, 1, 1, 0.010001 },
				padding = 0.01,
				r = 0.1,
				hover = true,
				button = 'bl_cycle_anchor_point',
				button_dist = 0,
				tooltip = { filler = { func = get_anchor_tooltip } }
			},
			nodes = {
				{ n = G.UIT.O, config = { id = 'icon', object = get_anchor_icon(self, args.config.anchor) } }
			}
		}

		local function get_settings_tooltip()
			return {
				n = G.UIT.R,
				nodes = {
					{
						n = G.UIT.T,
						config = {
							text = 'Settings',
							scale = 0.15,
							colour = G.C.UI.TEXT_DARK
						}
					},
				}
			}
		end

		local btn_settings = {
			n = G.UIT.C,
			config = {
				id = 'btn_settings',
				colour = { 1, 1, 1, 0.010001 },
				padding = 0.01,
				r = 0.1,
				hover = true,
				button = 'bl_open_settings',
				button_dist = 0,
				tooltip = { filler = { func = get_settings_tooltip } }
			},
			nodes = {
				{ n = G.UIT.O, config = { id = 'icon', object = settings_icon } }
			}
		}

		args.definition = {
			n = G.UIT.ROOT,
			config = {
				align = 'tr',
				colour = G.C.CLEAR,
			},
			nodes = {
				{
					n = G.UIT.C,
					config = {
						align = "cm",
						padding = 0.1,
						mid = true,
						r = 0.1,
						colour = { 0, 0, 0, 0.1 }
					},
					nodes = {
						{
							n = G.UIT.R,
							config = {
								align = 'cr',
							},
							nodes = {
								{
									n = G.UIT.C,
									config = {
										id = "header_container",
									},
									nodes = {
										args.header or nil
									}
								},
								{
									n = G.UIT.C,
									config = {
										minw = 0.1,
									},
									nodes = {}
								},
								{
									n = G.UIT.C,
									config = {
										id = "button_container",
									},
									nodes = {
										{
											n = G.UIT.R,
											nodes = { args.config.settings_func and btn_settings or nil, btn_lock, btn_anchor }
										}
									}
								}
							}
						},
						{
							n = G.UIT.R,
							nodes = args.nodes or {}
						}

					}
				}
			}
		}

		UIBox.init(self, args)

		self.states.drag.can = not args.config.locked
		self.states.anchor = args.config.anchor

		self:set_relative_pos(args.T.x or args.T[1] or self.T.x, args.T.y or args.T[2] or self.T.y)

		self.attention_text = 'MoveableContainer' -- Workaround so that this is drawn over other elements

		local header_container = self:get_UIE_by_ID('header_container')
		local header_align = header_container.align
		header_container.align = function(self, x, y)
			-- Left-align header while controls are right-aligned
			header_align(header_container, 0, y)
		end

		local btn = self:get_UIE_by_ID('btn_anchor')
		local btn_click = btn.click
		btn.click = function()
			btn_click(btn)
		end
		local is_hover = false
		local btn_hover = btn.hover
		btn.hover = function()
			is_hover = true
			btn_hover(btn)
		end
		local btn_stop_hover = btn.stop_hover
		btn.stop_hover = function()
			btn_stop_hover(btn)
			is_hover = false
		end

		if args.config.instance_type then
			table.insert(G.I[args.config.instance_type], self)
		else
			table.insert(G.I.UIBOX, self)
		end

		sendDebugMessage("MoveableContainer:init", TAG)
	end

	function MoveableContainer:remove()
		sendDebugMessage("MoveableContainer:remove", TAG)
		UIBox.remove(self)
	end

	function MoveableContainer:calculate_xywh(node, _T, recalculate, _scale)
		local old_rel_x, old_rel_y = self:get_relative_pos()
		local old_w, old_h = self.T.w, self.T.h

		local new_w, new_h = UIBox.calculate_xywh(self, node, _T, recalculate, _scale)


		if node == self.UIRoot and (new_w ~= old_w or new_h ~= old_h) then
			self:set_relative_pos(old_rel_x, old_rel_y)

			if G.SETTINGS.paused then
				self:hard_set_T(self.T.x, self.T.y, self.T.w, self.T.h)
			end
		end

		return new_w, new_h
	end

	function MoveableContainer:update(dt)
		UIBox.update(self, dt)
		self:get_UIE_by_ID('button_container').states.visible = self.states.collide.is
	end

	function MoveableContainer:set_relative_pos(x, y)
		local new_x, new_y = x, y

		if not self.states.anchor then
			return
		end

		if string.find(self.states.anchor, "Top") then
			-- Do nothing (y is correct)
		elseif string.find(self.states.anchor, "Bottom") then
			new_y = y - self.UIRoot.T.h
		else -- Mid
			new_y = y - self.UIRoot.T.h / 2
		end

		if string.find(self.states.anchor, "Left") then
			-- Do nothing (x is correct)
		elseif string.find(self.states.anchor, "Right") then
			new_x = x - self.UIRoot.T.w
		else -- Center
			new_x = x - self.UIRoot.T.w / 2
		end

		self.T.x = new_x
		self.T.y = new_y
	end

	function MoveableContainer:get_relative_pos()
		local x, y = self.T.x, self.T.y

		if not self.states.anchor then
			return x, y
		end

		if string.find(self.states.anchor, "Top") then
			-- Do nothing (y is correct)
		elseif string.find(self.states.anchor, "Bottom") then
			y = y + self.UIRoot.T.h
		else -- Mid
			y = y + self.UIRoot.T.h / 2
		end

		if string.find(self.states.anchor, "Left") then
			-- Do nothing (x is correct)
		elseif string.find(self.states.anchor, "Right") then
			x = x + self.UIRoot.T.w
		else -- Center
			x = x + self.UIRoot.T.w / 2
		end

		return x, y
	end

	function MoveableContainer:hover()
		if self.states.drag.can then
			local sizeall_cursor = love.mouse.getSystemCursor("sizeall")
			love.mouse.setCursor(sizeall_cursor)
		end

		UIBox.hover(self)
	end

	function MoveableContainer:stop_hover()
		local arrow_cursor = love.mouse.getSystemCursor("arrow")
		love.mouse.setCursor(arrow_cursor)

		UIBox.stop_hover(self)
	end

	function MoveableContainer:bl_toggle_lock()
		self.states.drag.can = not self.states.drag.can

		local btn_lock = self:get_UIE_by_ID("btn_lock")
		self:remove_UIE_by_ID('icon', btn_lock)

		local new_icon = get_lock_icon(self)
		self:add_child({ n = G.UIT.O, config = { id = 'icon', object = new_icon } }, btn_lock)

		btn_lock:stop_hover()
		btn_lock:hover()
	end

	function MoveableContainer:bl_cycle_anchor_point()
		local function get_next_anchor(anchor)
			local anchor_points = {
				"Top Right",
				"Right",
				"Bottom Right",
				"Bottom",
				"Bottom Left",
				"Left",
				"Top Left",
				"Top"
			}

			if not anchor then
				return anchor_points[1]
			end

			for i, a in ipairs(anchor_points) do
				if a == anchor then
					return anchor_points[i % #anchor_points + 1]
				end
			end

			error('Unknown anchor point ' .. tostring(self.states.anchor))
		end

		self.states.anchor = get_next_anchor(self.states.anchor)

		local btn_anchor = self:get_UIE_by_ID('btn_anchor')
		self:remove_UIE_by_ID('icon', btn_anchor)

		local new_icon = get_anchor_icon(self)
		self:add_child({ n = G.UIT.O, config = { id = 'icon', object = new_icon } }, btn_anchor)

		btn_anchor:stop_hover()
		btn_anchor:hover()
	end

	function MoveableContainer:bl_open_settings()
		if self.config and self.config.settings_func then
			self.config.settings_func('exit_overlay_menu')
		end
	end

	local function bl_toggle_moveablecontainer_lock(UIE)
		if not UIE or not UIE.UIBox then
			return
		end
		UIE.UIBox:bl_toggle_lock()
	end
	G.FUNCS.bl_toggle_moveablecontainer_lock = bl_toggle_moveablecontainer_lock

	local function bl_cycle_anchor_point(UIE)
		if not UIE or not UIE.UIBox then
			return
		end
		UIE.UIBox:bl_cycle_anchor_point()
	end
	G.FUNCS.bl_cycle_anchor_point = bl_cycle_anchor_point

	local function bl_open_settings(UIE)
		if not UIE or not UIE.UIBox then
			return
		end
		UIE.UIBox:bl_open_settings()
	end
	G.FUNCS.bl_open_settings = bl_open_settings
end

----------------------------------------------
------------MOD CODE END----------------------
