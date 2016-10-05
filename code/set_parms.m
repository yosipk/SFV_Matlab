function parms = set_parms(parms,fields_vals_tuples)

for n = 1:length(fields_vals_tuples)
    parms.(fields_vals_tuples{n}{1}) = fields_vals_tuples{n}{2};    
end
