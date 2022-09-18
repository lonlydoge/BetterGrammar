local Players = game:GetService("Players");
local LocalPlayer = Players.LocalPlayer;

local ChatHook;

local Marks = {{"?", {"how", "what", "why", "when", "who", "where"}}, {"!", {"stop"}}, {".", {}}}

local RemovePunctiation = function(Message)
    for _, Mark in ipairs(Marks) do
        local CMark = Mark[1];

        Message = string.gsub(Message, "%" .. CMark, "");
    end

    return Message;
end

local CheckForMark = function(Message)
    for _, Mark in ipairs(Marks) do
        local CMark = Mark[1];

        if string.sub(Message, #Message, #Message) == CMark then
            return CMark;
        end
    end

    return false;
end

local GrammarFunctions = {
    FCharacter = function(Message)
        local FirstCharacter = string.sub(Message, 1, 1);

        FirstCharacter = string.upper(FirstCharacter);

        Message = FirstCharacter .. string.sub(Message, 2, #Message);

        return Message;
    end,

    LCharacter = function(Message)
        local SMessage = string.split(Message, " ");
        local LCharacterFound = false;

        local LastCharacter = ".";

        if CheckForMark(Message) then
            return Message;
        end

        for _, Mark in ipairs(Marks) do
            local WordSequence = Mark[2];
            local CMark = Mark[1];

            for _, Word in ipairs(WordSequence) do
                if SMessage[1]:match(Word) then
                    LastCharacter = CMark;

                    LCharacterFound = true;
                end
            end

            if LCharacterFound then
                break
            end
        end

        return Message .. LastCharacter;
    end,

    ICapitilazation = function(Message)
        local SMessage = string.split(Message, " ");

        for Index, String in ipairs(SMessage) do
            if RemovePunctiation(String) == "i" then
                SMessage[Index] = string.upper(String);
            end
        end

        return table.concat(SMessage, " ");
    end,

    MWCorrection = function(Message)
        local SMessage = string.split(Message, " ");

        for Index, String in ipairs(SMessage) do
            local CFMark = CheckForMark(String);

            if CFMark then
                String = RemovePunctiation(String);
            end

            if string.lower(string.sub(String, #String, #String)) == "s" and
                string.lower(string.sub(String, #String - 1, #String)) ~= "es" and
                string.lower(string.sub(String, #String - 1, #String)) ~= "is" and
                string.lower(string.sub(String, #String - 2, #String)) ~= "ies" then
                if CFMark then
                    SMessage[Index] = string.sub(String, 1, #String - 1) .. "'s" .. CFMark;
                else
                    SMessage[Index] = string.sub(String, 1, #String - 1) .. "'s";
                end
            end

            if string.lower(string.sub(String, #String, #String)) == "t" and
                string.lower(string.sub(String, #String - 1, #String)) == "nt" then
                if CFMark then
                    SMessage[Index] = string.sub(String, 1, #String - 1) .. "'t" .. CFMark;
                else
                    SMessage[Index] = string.sub(String, 1, #String - 1) .. "'t";
                end
            end
        end

        return table.concat(SMessage, " ");
    end
}

local IGrammar = function(Message)
    for _, GFunction in pairs(GrammarFunctions) do
        Message = GFunction(Message);
    end

    return Message;
end

ChatHook = hookmetamethod(game, "__namecall", function(self, ...)
    local Arguments = {...};

    local Method = getnamecallmethod()

    if Method == "Fire" or Method == "FireServer" then
        if self.Name == "SayMessageRequest" then
            return ChatHook(self, IGrammar(Arguments[1]), Arguments[2]);
        end
    end

    return ChatHook(self, ...)
end)
