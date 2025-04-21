\documentclass{article}
\usepackage[a4paper,margin=1in]{geometry}
\usepackage{hyperref}
\usepackage{enumitem}

\title{Digital Circuit and System - Lab05: Nonlinear Function Implementation with DesignWare IP}
\author{Institute of Electronics, NYCU \\ NYCU CERES LAB}
\date{February 27, 2025}

\begin{document}

\maketitle

\section{Introduction}
This lab explores the implementation of nonlinear functions commonly used in artificial neural networks (ANNs) using Synopsys DesignWare IP. You are required to implement two floating-point nonlinear functions using a pipelined architecture to meet strict timing constraints.

\section{DesignWare IP Overview}
\begin{itemize}
    \item \textbf{DesignWare IP Types:}
    \begin{itemize}
        \item \textbf{Soft IP:} RTL-level, requires verification.
        \item \textbf{Firm IP:} Netlist-level, less commonly used.
        \item \textbf{Hard IP:} GDSII format, high performance, technology dependent.
    \end{itemize}
    \item \textbf{DesignWare Library:} Provides synthesizable and verified IPs for optimized area/speed and timing reduction.
\end{itemize}

\section{Project Description}
The objective is to implement two nonlinear functions using Synopsys DesignWare IP blocks:
\begin{itemize}
    \item Functions operate on IEEE 754 floating-point input.
    \item Must follow the given formulas for function computation.
    \item You must use floating-point arithmetic IP (e.g., \texttt{DW\_fp\_exp}, \texttt{DW\_fp\_log2}, etc.) in your design.
    \item The design must be pipelined to meet timing constraints.
\end{itemize}

\section{Input and Output Signals}
\begin{itemize}
    \item \textbf{in\_valid}: High when input data is valid.
    \item \textbf{out\_valid}: Must be pulled high within 7 cycles after in\_valid and remain high until all patterns are complete.
    \item Input and output delays are both \(0.5 \times \text{cycle time}\).
\end{itemize}

\section{Implementation Constraints}
\begin{itemize}
    \item You must reset all output signals after reset is asserted.
    \item You cannot change the clock cycle (fixed at 18ns).
    \item \textbf{exp(x)} is the most time-consuming operation and defines the cycle time.
    \item A pipelined design is \textbf{mandatory} to meet the 18ns timing constraint.
    \item You are not allowed to modify IEEE floating-point parameters.
\end{itemize}

\section{DesignWare IP Usage}
\begin{itemize}
    \item Refer to Synopsys documentation: \
    \texttt{/usr/cad/synopsys/synthesis/cur/dw/doc/manuals/dwbb\_userguide.pdf}
    \item Use Chapter 2 to learn how to instantiate IPs.
    \item Follow these steps:
    \begin{enumerate}[label=\arabic*.]
        \item Select appropriate IP (e.g., \texttt{DW\_fp\_log2}, \texttt{DW\_fp\_exp}).
        \item Read and understand pin and parameter descriptions.
        \item Copy template, fill in parameters, rename instance if needed.
    \end{enumerate}
\end{itemize}

\section{Useful References}
\begin{itemize}
    \item \href{https://www.youtube.com/watch?v=e_J9lXnU_vs}{YouTube – Neural Network Activation Functions}
    \item \href{https://www.sciencedirect.com/science/article/pii/S0925231219308884}{ScienceDirect – Activation Function Study}
\end{itemize}

\end{document}
