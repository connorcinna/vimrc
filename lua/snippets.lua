-- snippets

local ls = require("luasnip")
-- LuaSnip snippet for C# XML documentation comments
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node

ls.add_snippets("cs", {
	s("///", {
		t("/// <summary>"),
		t({ "", "/// " }),
		i(1, "Description"),
		t({ "", "/// </summary>" }),
		-- Add <param> or <returns> dynamically if needed
		t({ "", '/// <param name="' }),
		i(2, "param"),
		t('">'),
		i(3, "Description"),
		t("</param>"),
		t({ "", "/// <returns>" }),
		i(4, "void"),
		t("</returns>"),
	}),
})

ls.add_snippets("cs", {
	s("///", {
		t("/// <summary>"),
		t({ "", "/// " }),
		i(1, "Description"),
		t({ "", "/// </summary>" }),
		-- Add <param> or <returns> dynamically if needed
		t({ "", '/// <param name="' }),
		i(2, "param"),
		t('">'),
		i(3, "Description"),
		t("</param>"),
		t({ "", "/// <returns>" }),
		i(4, "void"),
		t("</returns>"),
	}),
})

ls.add_snippets("cs", {
	s("seealso", {
		t('<seealso href="link"/>'),
	}),
})

ls.add_snippets("cs", {
	s("inheritdoc", {
		t("/// <inheritdoc/>"),
	}),
})

ls.add_snippets("cs", {
	s("///desc", {
		t("/// <summary>"),
		t({ "", "/// " }),
		i(1, "Description"),
		t({ "", "/// </summary>" }),
	}),
})
