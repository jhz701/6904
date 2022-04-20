% Comparing the sent code and the received code and calculate BER
% Ideally, for N codes, the matrix should have the size of N*5
function result = BER(sent,received)
    N = length(sent);
    j = 0;
    for i = 1:N
        compare = (sent(i,:) ~= received(i,:));
        if(sum(compare)~=0)
            j = j+1; % incorrect codes
        end
    end
    result = j/N; % bit error rate
end