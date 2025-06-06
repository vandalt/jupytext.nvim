local M = {}

local language_extensions = {
  python = "py",
  julia = "jl",
  r = "r",
  R = "r",
  bash = "sh",
}

local language_names = {
  python3 = "python",
}

M.get_ipynb_metadata = function(filename)
  local metadata = vim.json.decode(io.open(filename, "r"):read "a")["metadata"]
  local language
  -- TODO: Make configurable
  if metadata.kernelspec == nil then
    language = "python"
  else
    language = metadata.kernelspec.language
  end
  if language == nil then
    language = language_names[metadata.kernelspec.name]
  end
  local extension = language_extensions[language]

  return { language = language, extension = extension }
end

M.get_jupytext_file = function(filename, extension)
  local fileroot = vim.fn.fnamemodify(filename, ":r")
  return fileroot .. "." .. extension
end

M.check_key = function(tbl, key)
  for tbl_key, _ in pairs(tbl) do
    if tbl_key == key then
      return true
    end
  end

  return false
end

M.get_empty_notebook = function()
  -- Ref: https://github.com/benlubas/molten-nvim/blob/main/docs/Notebook-Setup.md
  -- TODO: Other fts
  local empty_notebook = [[
    {
      "cells": [
      {
        "cell_type": "markdown",
        "metadata": {},
        "source": [
          ""
        ]
      }
      ],
      "metadata": {
      "kernelspec": {
        "display_name": "Python 3",
        "language": "python",
        "name": "python3"
      },
      "language_info": {
        "codemirror_mode": {
          "name": "ipython"
        },
        "file_extension": ".py",
        "mimetype": "text/x-python",
        "name": "python",
        "nbconvert_exporter": "python",
        "pygments_lexer": "ipython3"
      }
      },
      "nbformat": 4,
      "nbformat_minor": 5
    }
  ]]
  return empty_notebook
end

M.create_new_notebook = function(path)
  -- Ref: https://github.com/benlubas/molten-nvim/blob/main/docs/Notebook-Setup.md
  local file = io.open(path, "w")
  if file then
    file:write(M.get_empty_notebook())
    file:close()
  else
    -- TODO: Proper error
    print("Error: Could not open new notebook file for writing.")
  end
end

M.is_empty_or_new = function(filename)
  -- Ref: https://github.com/GCBallesteros/jupytext.nvim/pull/31/files
  local file = io.open(filename, "r")
  if not file then
    return true
  end
  local file_content = file:read "a"
  file:close()
  return file_content == ""
end


return M
