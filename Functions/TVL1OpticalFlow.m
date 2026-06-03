%% Function of TV-L1 Optical Flow Estimation
% Former Author: Vinthony, JoeyBG;
% Improved By: JoeyBG;
% Affiliation: Beijing Institute of Technology, Radar Research Lab;
% Date: 2026-06-03;
% Language & Platform: MATLAB R2025b.
%
% Introduction:
% This function provides a compact TV-L1-compatible optical-flow solver used
% as the high-accuracy candidate of the mDOF extraction module.

function [u,v] = TVL1OpticalFlow(Frame_0,Frame_1)

    I0 = single(NormalizeDTMIntensity(Frame_0));
    I1 = single(NormalizeDTMIntensity(Frame_1));

    Levels = [4 2 1];
    um = zeros(2,2,"single");
    vm = um;
    pli = zeros(2,2,"single");

    for gp = Levels
        fs = fspecial("gaussian",[5 5],0.8);
        wI0 = imresize(conv2(double(I0),fs,"same"),size(I0)/gp,"bilinear");
        wI1 = imresize(conv2(double(I1),fs,"same"),size(I0)/gp,"bilinear");
        [M,N] = size(wI0);

        p11 = imresize(pli,size(I0)/gp,"bilinear");
        p12 = p11;
        p21 = p11;
        p22 = p11;
        [um,vm] = ResizeFlowTVL1(um,vm,size(I0)./gp);

        for Warped_Index = 1:10
            D = zeros(M,N,2);
            D(:,:,1) = um;
            D(:,:,2) = vm;
            Iw1 = imwarp(wI1,D);

            residual = sqrt((Iw1 - wI0).^2 + 1e-10);
            dd = (Iw1 - wI0) ./ sqrt((Iw1 - wI0).^2 + 1e-10);
            [g1x,g1y] = gradient(Iw1);
            Iw1x = g1x .* dd;
            Iw1y = g1y .* dd;
            grad = Iw1x .* Iw1x + Iw1y .* Iw1y;
            rho_c = residual - Iw1x .* um - Iw1y .* vm;

            [um,vm,p11,p12,p21,p22] = OptimizeTVL1( ...
                um,vm,grad,rho_c,Iw1x,Iw1y,p11,p12,p21,p22);
        end
    end

    u = um;
    v = vm;

end

function [umo,vmo,p11,p12,p21,p22] = OptimizeTVL1(um,vm,grad,rho_c,Iw1x,Iw1y,p11,p12,p21,p22)

    epsilon = 1e-2;
    OUT_ITERATION = 10;
    INNER_ITERATION = 30;
    tau = 0.25;
    [M,N] = size(vm);
    theta = 0.1;
    lambda = 50;
    taut = tau / theta;
    n_outer = 0;
    error_value = inf;

    while error_value > epsilon * epsilon && n_outer < OUT_ITERATION
        n_outer = n_outer + 1;
        n_inter = 0;
        um = medfilt2(um,[5 5],"symmetric");
        vm = medfilt2(vm,[5 5],"symmetric");

        while error_value > epsilon * epsilon && n_inter < INNER_ITERATION
            n_inter = n_inter + 1;
            [v1,v2] = EigenUpdate2D(grad,rho_c,Iw1x,Iw1y,um,vm,lambda,theta);
            div_p1 = Div2D(p11,p12);
            div_p2 = Div2D(p21,p22);
            um0 = um;
            vm0 = vm;
            um = v1 + theta .* div_p1;
            vm = v2 + theta .* div_p2;
            e = (um0 - um) .* (um0 - um) + (vm0 - vm) .* (vm0 - vm);
            error_value = sum(e(:)) / (M * N);

            [umx,umy] = ForwardGradient2D(um);
            [vmx,vmy] = ForwardGradient2D(vm);
            g1 = sqrt(umx .* umx + umy .* umy);
            g2 = sqrt(vmx .* vmx + vmy .* vmy);
            p11 = (p11 + taut .* umx) ./ (1 + taut .* g1);
            p12 = (p12 + taut .* umy) ./ (1 + taut .* g1);
            p21 = (p21 + taut .* vmx) ./ (1 + taut .* g2);
            p22 = (p22 + taut .* vmy) ./ (1 + taut .* g2);
        end
    end

    umo = um;
    vmo = vm;

end

function [v1,v2] = EigenUpdate2D(grad,rho,Sx,Sy,um,vm,lambda,theta)

    [m,n] = size(um);
    v1 = zeros(m,n);
    v2 = v1;
    l_t = lambda * theta;

    for y = 1:m
        for x = 1:n
            dx = 0;
            dy = 0;
            rhoc = rho(y,x) + Sx(y,x) .* um(y,x) + Sy(y,x) .* vm(y,x);

            if rhoc < -l_t * grad(y,x)
                dx = l_t * Sx(y,x);
                dy = l_t * Sy(y,x);
            elseif rhoc > l_t * grad(y,x)
                dx = -l_t * Sx(y,x);
                dy = -l_t * Sy(y,x);
            elseif grad(y,x) > 0
                dx = -rhoc / grad(y,x) * Sx(y,x);
                dy = -rhoc / grad(y,x) * Sy(y,x);
            end

            v1(y,x) = um(y,x) + dx;
            v2(y,x) = vm(y,x) + dy;
        end
    end

end

function [um,vm] = ResizeFlowTVL1(um,vm,new_size)

    scaling = single([new_size(1) / size(um,1),new_size(2) / size(um,2)]);
    a = linspace(1,size(um,2),new_size(2));
    b = linspace(1,size(um,1),new_size(1));
    [xi,yi] = meshgrid(a,b);
    xi = single(xi);
    yi = single(yi);
    um = interp2(single(um) .* scaling(2),xi,yi);
    vm = interp2(single(vm) .* scaling(1),xi,yi);
    um(isnan(um)) = 0;
    vm(isnan(vm)) = 0;

end

function D = Div2D(PX,PY)

    [m,n] = size(PX);
    D = zeros(size(PX));

    for yi = 2:m
        for xi = 2:n
            dvx = PX(yi,xi) - PX(yi,xi-1);
            dvy = PY(yi,xi) - PY(yi-1,xi);
            D(yi,xi) = dvx + dvy;
        end
    end

    for xi = 2:n
        D(1,xi) = PX(1,xi) - PX(1,xi-1) + PY(1,xi);
    end

    for yi = 2:m
        D(yi,1) = PX(yi,1) + PY(yi,1) - PY(yi-1,1);
    end

    D(1,1) = PX(1,1) + PY(1,1);

end

function [Ix,Iy] = ForwardGradient2D(I)

    [m,n] = size(I);
    Ix = zeros(size(I));
    Iy = Ix;

    for y = 1:m-1
        for x = 1:n-1
            Ix(y,x) = I(y,x+1) - I(y,x);
            Iy(y,x) = I(y+1,x) - I(y,x);
        end
    end

    for x = 1:n-1
        Ix(m,x) = I(m,x+1) - I(m,x);
        Iy(m,x) = 0.0;
    end

    for y = 1:m-1
        Ix(y,n) = 0.0;
        Iy(y,n) = I(y+1,n) - I(y,n);
    end

    Ix(m,n) = 0.0;
    Iy(m,n) = 0.0;
    Ix = single(Ix);
    Iy = single(Iy);

end
