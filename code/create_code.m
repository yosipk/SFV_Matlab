function code = create_code(fields_vals_tuples)

code = '';

for n = 1:length(fields_vals_tuples)
    cur_field = fields_vals_tuples{n}{1};
    pos = [0 strfind(cur_field,'_')] + 1;
    if (isa(fields_vals_tuples{n}{2},'numeric'))
        text = num2str(fields_vals_tuples{n}{2});
    elseif (isa(fields_vals_tuples{n}{2},'char'))
        text = fields_vals_tuples{n}{2};
    else
        error('Parameter value can be numeric or text only');
    end
    code = strcat(code,'_',cur_field(pos), text);
end
