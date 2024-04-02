function [eta2] = getEta2(mdl, y)

y_est = fitted(mdl);
eta2 = var(y_est, 'omitnan')/var(y, 'omitnan');

end

