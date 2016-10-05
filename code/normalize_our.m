function vecs = normalize_our(vecs, norm, dim)        
  if (~isinf(norm))
    norms = (sum(abs(vecs).^norm,dim)).^(1/norm);
  else
    norms = max(vecs,[],dim);
  end

  vecs = bsxfun(@rdivide,vecs,norms);
end
