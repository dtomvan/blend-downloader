local meta = {}

local function dump(o)
    if type(o) == 'table' then
        local s = '{ '
        for k, v in pairs(o) do
            if type(k) ~= 'number' then k = '"' .. k .. '"' end
            s = s .. '[' .. k .. '] = ' .. dump(v) .. ','
        end
        return s .. '} '
    else
        return tostring(o)
    end
end

local function get_tag(t)
    return function(e)
        return e.tag == t
    end
end

get_metadata = {
    Div = function(el)
        local header = el.content:find_if(get_tag 'Header')
        local list = el.content:find_if(get_tag 'BulletList')
        if not (el.classes:find 'fusion-text' and header) then
            return
        end
        local title = header.content:find_if(get_tag 'Strong')
        if not title then
            return
        end
        local name = ""
        title.content:walk {
            Str = function(s) name = name .. s.text end,
            Space = function() name = name .. ' ' end,
        }
        if #name > 0 then
            local urls = {}
            list.content:map(function(p)
                p:walk {
                    Plain = function(p)
                        local link = p.content:find_if(get_tag 'Link')
                        if not link then return end
                        table.insert(urls, link.target)
                    end
                }
            end)
            meta[name] = urls
        end
    end
}

function Pandoc(document)
    document.blocks:walk(get_metadata)
    print(pandoc.json.encode(meta))
    os.exit(0)
end
