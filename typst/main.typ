#import "@preview/oxifmt:0.3.0": strfmt

#import "@preview/muchpdf:0.1.1": muchpdf
#let pdf(path, ..args) = box(
  muchpdf(read(path, encoding: none), ..args),
  inset: (y: -1em),
)

#set page("a4", margin: (inside: 3cm, outside: 2cm, top: 2.5cm, bottom: 3.5cm))

#let text-main = rgb(10, 10, 20)
#let bg-main = rgb(150, 95, 120)
#let bg-light = rgb(245, 245, 245)

#set text(font: "Baskervald ADF Std", size: 11pt, fill: text-main)
#set par(leading: 1em, spacing: 2em, justify: true)
#set figure(numbering: num => {
  let loc = counter(heading).get().first()
  str(loc) + "." + str(num)
})
#show figure: set block(inset: (top: 0.5em, bottom: 0.5em))
#show figure.caption: set text(size: 0.8em)

#show heading.where(level: 1): it => {
  let num = counter(heading).at(here()).first()
  set text(24pt, weight: "bold")
  set par(justify: false)

  pagebreak(to: "odd", weak: false)

  v(3em)

  stack(dir: ttb, spacing: 2em, text(size: 20pt, [Chapter #num]), it.body)

  v(1em)
}
#show heading: set block(inset: (y: 0.8em))
#show heading.where(level: 2): set text(size: 14pt)
#show heading.where(level: 3): set text(size: 12pt)

#show outline.entry.where(level: 1): it => {
  block(inset: (top: 1em), text(weight: "bold", it))
}
#show heading: set heading(numbering: "1.")

#let box-spacing = 1em
#set block(spacing: box-spacing)
#set columns(gutter: box-spacing)

#set math.equation(numbering: num => {
  let loc = counter(heading).get().first()
  "(" + str(loc) + "." + str(num) + ")"
})
#show math.equation.where(block: true): set block(spacing: 1.5em)

#show raw.where(block: true): it => {
  set text(size: 1.1em)
  block(width: 100%, inset: 1em, fill: bg-light, {
    let lines = it.text.split("\n")
    let numbered = range(1, lines.len() + 1).map(str)
    grid(
      align: horizon + left,
      columns: (auto, 1fr),
      row-gutter: 0.7em,
      column-gutter: 2em,
      ..numbered
        .map(n => (
          grid.cell(text(fill: bg-main, strfmt("{:>02}", n))),
          grid.cell(raw(lines.at(int(n) - 1), lang: it.lang)),
        ))
        .flatten()
    )
  })
}

#let hr = box(inset: (y: 1em), line(length: 100%, stroke: 2pt + bg-main))

#let clearpage() = page()[]

#let page-without-numbering(body, title: none) = {
  align(horizon)[
    #text(size: 2.2em, weight: "bold")[#title]
    #v(3em)
    #body
  ]
}

#let INDEX = sys.inputs.at("INDEX", default: "TODO")
#let EVIDENCE = sys.inputs.at("EVIDENCE", default: "TODO")

#let thesis-title-en = "Influence of the reconstruction efficiency on the angular correlation functions in Run 3 software in ALICE."
#let thesis-title-pl = "Wpływ wydajności rekonstrukcji śladów cząstek na kątowe funkcje korelacyjne w oprogramowaniu Run 3 w eksperymencie ALICE."

#align(center)[
  #stack(
    dir: ttb,
    spacing: 4.5em,
    image("img/WF_ENG.png", width: 100%),
    image("img/mgr_en.png", width: 70%),
    text(size: 1.1em)[
      in the field of study Fizyka Techniczna \
      and specialization EDMI
    ],
    stack(
      spacing: 2em,
      text(size: 1.6em, weight: "bold")[
        #set par(justify: false)
        #thesis-title-en
      ],
      text(size: 1.1em)[
        thesis number according to Faculty's thesis evidence: #EVIDENCE
      ],
    ),
    stack(spacing: 2em, text(size: 1.5em)[Dawid Karpiński], text(
      size: 1.1em,
    )[student record book number: #INDEX]),
    stack(
      spacing: 2em,
      text(size: 1.1em)[
        supervisor: \
        dr hab. inż. Małgorzata Janik
      ],
      text(size: 1.1em)[
        second supervisor: \
        dr hab. inż. Łukasz Graczykowski
      ],
    ),
    v(1fr),
    text(size: 1.1em)[WARSAW #datetime.today().year()],
  )
]

#clearpage()

#text(size: 1.3em)[Abstract]
#hr

*Thesis title:* #thesis-title-en
#v(1em)

#lorem(40)

#v(2em)
_Keywords:_

#v(1fr)
#stack(dir: ltr, spacing: 1fr, "supervisor's signature", "student's signature")

#clearpage()

#text(size: 1.3em)[Streszczenie]
#hr

*Tytuł pracy:* #thesis-title-pl
#v(1em)

#lorem(40)

#v(2em)
_Słowa kluczowe:_

#v(1fr)
#stack(dir: ltr, spacing: 1fr, "podpis opiekuna naukowego", "podpis studenta")

#clearpage()

#page-without-numbering(title: "Contents")[
  #outline(title: none)
]

#clearpage()

#set page(footer: context {
  let page-number = here().page()
  let is-even = calc.rem(page-number, 2) == 0

  rect(stroke: (top: 2pt + bg-main), width: 100%, inset: (top: 1em))[
    #align(if is-even { left } else { right })[
      #page-number
    ]
  ]
})

= Introduction

== LHC and Run 3

The *Large Hadron Collider* (LHC), located at the European Organization for Nuclear Research (CERN) near Geneva, Switzerland, stands as the world's largest particle accelerator. Created in 2008, it accelerates and collides particles, primarily protons and heavy ions (e.g., lead). These collisions produce a variety of subatomic particles, allowing us to test predictions of the Standard Model and search for new phenomena beyond it.

The collider has completed two successful periods of data collection, the first Run 1 (2010--2013), and the other Run 2 (2015--2018). The current operational phase, *Run 3*, began in 2022 following the second, long shutdown (LS2) @lhc-upgrade. After numerous upgrades, the LHC now features proton-proton collisions at a center-of-mass energy of 13.6 [TeV], an increase from the 13 [TeV] utilized in Run 2. This higher energy helps in further studies and improves measurement precision and analysis statistics.


== The ALICE experiment

The acronym ALICE stands for *A Large Ion Collider Experiment*, one of four major experiments at the LHC. The detector enables the study of the quark-gluon plasma (QGP), a state with conditions resembling those a few millionths of a second after the Big Bang, before quarks and gluons combined to form protons and neutrons. Heavy ion nucleus-nucleus collisions can produce such a state. In the case of ALICE, the focus lies on lead-lead (Pb-Pb) collisions @alice-cern. The experiment also includes proton-nucleus collisions, as well as analysis of proton-proton collisions as reference data.

== Two-particle angular correlation function

This thesis focuses on $Delta eta Delta phi$ particle correlations derived from proton-proton collision data collected in the ALICE experiment.

// TODO: why these angles in particular?

=== Pseudorapidity and azimuthal angle

// TODO: angles, coordinate system

One can construct the angular correlation function using two quantities: pseudorapidity, $eta$, and azimuthal angle, $phi$. Both represent different aspects of a particle's trajectory in the detector.

#figure(image("img/detector-angles.png", width: 80%), caption: [
  Showcase of the angles considered in angular correlation function analysis.
]) <fig:detector-angles>

First, the pseudorapidity, $eta$, relates to the angle between the particle momentum $p$ and the beam axis ($theta$, @fig:detector-angles) as:
$
  eta = -ln [tan(theta/2)].
$

The azimuthal angle on the other hand represents the angle between the $x$-axis and the projection, $p_T$, of the momentum vector onto the $x y$-plane ($phi$, @fig:detector-angles).

However, the analysis of two-particle correlation accounts for the differences between both angles, expressed as $Delta eta = eta_1 - eta_2$ and $Delta phi = phi_1 - phi_2$.

=== Angular correlation function

To construct the $Delta eta Delta phi$ correlation function, one first obtains the so-called *signal distribution*, $S(Delta eta, Delta phi)$, by pairing every particle with every other particle, all within the same event.

Next, through the event mixing, in which pairs consist of particles from different events, one can calculate the *background distribution*, $B(Delta eta, Delta phi)$. This aids in eliminating any single-particle effects.

// TODO: write more why?

As the last step, one should normalize both distributions normalized by the corresponding numbers of pairs in the same events, $N_"same"$, and mixed events, $N_"mixed"}$, respectively.

Finally, the formula for the angular correlation function takes the form:
$
  C(Delta eta, Delta phi) = S(Delta eta, Delta phi) / B(Delta eta, Delta phi) N_"mixed" / N_"same".
$

== Correction procedure

The correction procedure aims to mitigate biases, that arise during the actual experiment.

Obtaining the weights used for correction happens based on data collected through Monto Carlo simulations (MC for short). Generated collisions follow set parameters, producing many particles referred to as *MC truth*. Extracted directly from the event itself, these particles remain unaffected by any effects that might come e.g. from detectors. Furthermore, the tracks of the same particles run through detectors for reconstruction and classification, hence called *MC reconstructed*.

#pagebreak()

=== Reconstruction efficiency

Therefore, calculation of reconstruction efficiency involves taking the ratio of the number of reconstructed particles to the number of simulated (true) particles:
$
  epsilon = N_"recon." / N_"truth".
$ <eq:efficiency>

#figure(image("img/efficiency.png", width: 60%), caption: [
  Tracks of simulated and reconstructed particles. Successful
  identification shown in green.
]) <fig:reco-truth-tracks>

// TODO: transverse momentum, mc reco, mc truth, detection

=== Secondary contamination

However, ensuring the correct results in the efficiency calculations requires consideration of only the primary particles.

The secondary contamination, $C$, described as the ratio of the number of secondary particles over all recorded particles, can affect the efficiency results. By taking it into account, one ensures that the final weights base only on the primary particles and not byproducts of other events.

#figure(
  grid(
    columns: 2,
    rows: 2,
    gutter: 2em,
    pdf("../data/LHC24f3c_fix/p-ap/contamination_p.pdf"),
    pdf("../data/LHC24f3c_fix/p-ap/contamination_ap.pdf"),

    pdf("../data/LHC24f3c/pi-api/contamination_pi.pdf"),
    pdf("../data/LHC24f3c/pi-api/contamination_api.pdf"),
  ),
  caption: [
    Showcase of the contamination percentage in the given data sample for pions, protons, kaons.
  ],
) <fig:contamination-proton>

As shown in @fig:contamination-proton, contamination for protons exceeds that of pions. This difference results from the lower number of protons in the data sample, especially in lower range of transverse momentum.

// TODO: anything else?


=== Efficiency correction weights

Having calculated the efficiency histogram and secondary contamination, one can calculate the weights as:
$
  w(p_T, …) = (1 - C(p_T, …)) / epsilon(p_T, …).
$

The values of $C$ and $epsilon$ typically come from histograms binned in transverse momentum ($p_T$) or in two dimensions as a function of both $p_T$ and pseudorapidity ($eta$), enabling a more accurate study of the efficiency and efficiency corrections.


= Extending FemtoUniverse in the O2Physics framework

== Framework — O2 and O2Physics

The major upgrade during Long Shutdown 2, introduced a new computing system called *Online-Offline (O2)*. This system replaces the previous data processing model with a more efficient approach that minimizes data volume through online track reconstruction. To support this, ALICE deployed two specialized computing farms: the First Level Processor (FLP) farm in Counting Room 1 (CR1) and the Event Processing Node (EPN) farm in Counting Room 0 (CR0). The FLP farm first reduces raw detector data from 3.5 TB/s to 900 GB/s by performing initial data suppression before sending it via Infiniband to the EPN farm. There, the first reconstruction pass further reduces the data to 130 GB/s, which then gets written to permanent storage. @alice-o2

The O2 framework introduces an entirely new software ecosystem, designed from scratch to support this architecture, by handling detector readout, data quality control, and operational services. *O2Physics* on the other hand acts as the complementary part to O2 for the LHC data analysis. It provides a way to define and run analysis tasks, which then get executed in parallel on the cluster. Designed to be flexible and extendable, the framework allows physicists to add their own analyses and modify existing ones.

Illustrated in Figure \ref{fig:o2-flow}, the flow of data processing in O2Physics starts with a specialized task called a producer. It parses the data into tables with a well-defined structure named *FemtoDerived*. After preprocessing, the analysis tasks run against the tables, generating visualizations in form of histograms and other plot types.

#figure(image("img/o2-flow.png", width: 90%), caption: [
  The data flow in O2Physics.
]) <fig:o2-flow>

== The old approach for efficiency correction

Until now, the O2Physics framework has lacked a universal and automated implementation of the reconstruction efficiency correction. The older framework for Run 2 included it, however as in the recent Run 3, individual analysis tasks in the new software either have not applied the correction or have implemented it in an isolated, highly specific way.

To calculate efficiency, the O2Physics framework relied on the `femtoUniverseEfficiencyBase.cxx` task. Since each task contains its own separate set of configurable parameters, this approach required manually synchronizing the efficiency task with the main analysis task. Such an error-prone and time-consuming process demanded a careful mirroring of every change across all analyses. The introduction of any potential inconsistencies could consequently reduce the reliability of the final results.

Therefore, a large part of this work revolves around developing a generic method in O2Physics, so that the application of the corrections can be easily added to any analysis task.

== The initial idea

A key aspect of the Run 3 upgrade involved shifting to a triggerless readout system, which requires real-time lossy data compression. Traditionally, systems have executed certain data processing tasks offline, but the new system integrates them directly into the front end of data acquisition. To facilitate this transition, ALICE introduced a centralized system called Calibration and Conditions Data base (CCDB) @ccdb-alice-run3. As its main design goal, it stores and retrieves the calibration data and ensures real-time propagation of updates to the online cluster while asynchronously synchronizing content with Grid storage for later access. Researchers can retrieve the data through a REST API or a ROOT-based C++ client, which integrates directly with the O2 and O2Physics frameworks.

The goal of the new approach for correction builds on the idea of using the CCDB to store and retrieve the correction data efficiently. The O2 framework provides a programmatic interface to the service, which makes the process easy to integrate for own needs. With this, analysis tasks can access correction factors from a central place, ensuring consistency.

After many attempts to implement the corrections application in the O2Physics framework, the new approach would replace task-specific solutions with a single, reusable method. This effort led to the creation of a class, `FemtoUniverseEfficiencyCorrection.h`, which serves as an abstraction for other analysis tasks to use.

My first solution (@fig:workflow-initial) leveraged the O2 framework's so-called callback service, which allows any task to register a callback function that would execute custom code on special dispatched events, e.g. `Start`, `Stop`, `EndOfStream`, etc. The `CallbackService.h` file lists all the available event IDs @callback-service. I have settled for `Stop` event (listing @lst:callback-service-code), on which a callback uploaded the calculated correction factors to the CCDB only once, at the end of the analysis task execution. It used the `CCDBApi::storeAsTFileAny` method to interact with the CCDB @ccdbapi-store. This flow has worked as expected when running locally.

#figure(image("img/workflow-initial.png", width: 70%), caption: [
  Visualization of the initial workflow for efficiency correction.
]) <fig:workflow-initial>

#figure(
  ```cpp
  void init(InitContext&) {
      // use the callback service
      auto& callbacks = ic.services().get<CallbackService>();
      // register the callback on the `Stop` event
      callbacks.set<o2::framework::CallbackService::Id::Stop>([this]() {
          ccdbApi.storeAsTFileAny(
              hist, // histogram to upload
              ccdbFullPath, // full path to CCDB
              createMetadata() // metadata of the object
              // …
          );
      });
      // …
  }
  ```,
  caption: [
    Code snippet for the initial idea leveraging the callback service.
  ],
) <lst:callback-service-code>

However, the above idea has a major drawback. It assumes that the analysis task runs on a single machine, which is not the case when running in a parallel and a distributed environment, e.g. the Worldwide LHC Computing Grid.

The *WLCG*, simply referred to as _Grid_, constitutes a global collaboration of approximately 170 computing centers across more than 40 countries. This computing infrastructure integrates around 1.4 million computer cores and 1.5 exabytes of storage. Its primary objective involves storing, distributing, and analyzing the substantial amounts of data generated annually by the Large Hadron Collider (LHC) at CERN.

Therefore, when running the task on the Grid, the system splits a given dataset into smaller chunks, processes each in parallel on individual nodes (machines), and eventually merges the results. This aspect causes the custom callback to execute as many times as the number of jobs created.

== The new workflow for efficiency correction

The initial ideas for the correction procedure proved unusable at such large scale. I changed the workflow direction to accommodate the Grid's parallel nature. Unfortunately, I did not achieve full automation, but I have integrated key features that allow for flexibility (@fig:workflow-temp).

#figure(image("img/workflow-temp.png", width: 100%), caption: [
  Visualization of the next workflow idea for efficiency correction.
]) <fig:workflow-temp>

The first step requires generating a histogram of reconstruction efficiency weights for the desired particle type. For this, I have created a ROOT macro that acts as an initial utility for the rest of the flow. The macro retrieves the required histograms from a results file that Grid generated at the end of a run. Once it gets the data, it calculates the ratio bin-by-bin (listing @lst:corr-macro-eff), between reconstructed and truth histograms to calculate the efficiency as stated in the formula @eq:efficiency.

#figure(
  ```cpp
  auto* hist_eff {clone_histogram(hist_reco_true, "hEfficiency")};

  for (auto bin_idx {1}; bin_idx <= hist_eff->GetNbinsX(); ++bin_idx) {
      auto reco_value {hist_reco_true->GetBinContent(bin_idx)};
      auto truth_value {hist_truth->GetBinContent(bin_idx)};

      auto eff {(truth_value > 0) ? reco_value / truth_value : 0};
      hist_eff->SetBinContent(bin_idx, eff);
  }
  ```,
  caption: [
    Snippet of the correction macro - efficiency calculation.
  ],
) <lst:corr-macro-eff>

Next, it assesses contamination from secondary sources by reusing already available histograms, that contain the information about the origin of each particle. For the workflow to work, the two-dimensional histograms of Distance of the Closest Approach (DCA) needed a projection onto $p_T$ axis, hence reducing to one dimension @lst:corr-macro-cont. Eventually, the contamination histogram consists of secondary contamination and contamination from material.

#figure(
  ```cpp
  // Get the projection from DCA histograms
  auto* hist_x {hist->ProjectionX(("h" + name).c_str())};

  // …
  // Calculate the contamination
  for (int bin_idx = 1; bin_idx <= hist_x->GetNbinsX(); ++bin_idx) {
      auto cont_value {hist_x->GetBinContent(bin_idx)};
      auto reco_value {hist_reco->GetBinContent(bin_idx)};
      hist_x->SetBinContent(bin_idx, reco_value > 0 ? cont_value / reco_value : 0);
  }

  // …
  auto* hist_secondary_x {get_histogram<TH1D>(output_file, "hDaughter")};
  auto* hist_material_x {get_histogram<TH1D>(output_file, "hMaterial")};
  hist_secondary_x->Add(hist_material_x);
  ```,
  caption: [
    Snippet of the correction macro - secondary contamination.
  ],
) <lst:corr-macro-cont>

The macro then computes the final weights by combining the efficiency and secondary contamination distributions to write the resulting histograms into a new ROOT file @lst:corr-macro-weig.

#figure(
  ```cpp
  auto* weights {clone_histogram(hist_secondary_x, "hWeights")};
  for (int bin_idx = 1; bin_idx <= weights->GetNbinsX(); ++bin_idx) {
      auto cont_value {hist_secondary_x->GetBinContent(bin_idx)};
      auto eff_value {hist_eff->GetBinContent(bin_idx)};

      // Combine efficiency and contamination
      auto weight {(eff_value > 0) ? (1 - cont_value) / eff_value : 1};
      weights->SetBinContent(bin_idx, weight);
  }
  ```,
  caption: [
    Snippet of the correction macro - correction weights.
  ],
) <lst:corr-macro-weig>

As the next major step, one needs to upload correction weights histogram to the CCDB, in a form of ROOT object file. The O2 developer environment (`alienv`) comes with a helpful tool called `o2-ccdb-upload` that abstracts all the details from the user, and allows to easily add any ROOT file to the CCDB. The listing \ref{lst:ccdb-upload-cmd} contains an exemplary usage of the tool for the case of the correction weights histogram.

#figure(
  ```bash
  o2-ccdb-upload \
      --host http://alice-ccdb.cern.ch \
      --path Users/d/dkarpins/Correction \
      --file ./EfficiencyCorrection.root \
      --key hWeights
  ```,
  caption: [
    Example command for the CCDB upload.
  ],
) <lst:ccdb-upload-cmd>

The core of this solution is `FemtoUniverseEfficiencyCorrection` class @efficiency-correction-class, that extends analysis tasks within the O2Physics framework, and allows for querying for the uploaded files, through the same interface as in the initial idea (listing @lst:callback-service-code). Additionally, the class utilizes configurable parameters to determine whether to apply corrections, specify the CCDB URL and histogram paths and timestamps for histogram objects retrieval.

== Extending corrections beyond 1D - the final solution

As the final development step, we wanted to generalize the correction procedure. Hence, I opted to expand it beyond a single dimension ($p_{T}$ axis) to support two‐ and three‐dimensional correction weights by filling 3D histograms with variables such as $p_{T}$, $eta$ and event centrality (or multiplicity). This approach unifies the calculation of reconstruction efficiency, secondary contamination and final weights across any combination of the variables.

When the user specifies a projection through a flag, the macro calls ROOT's `Project3D()` method to collapse the third axis into a 1D or 2D distribution (@lst:corr-macro-proj).

The rest of the correction macro, along with the remaining steps of the correction procedure, follow the same structure as the previous workflow.

// \begin{lstlisting}[caption={\label{lst:corr-macro-proj} Snippet of the correction macro - projection.}]
#figure(
  ```cpp
  auto* hist_truth_3d {get_hist(results_file, hist_path / "hMCTruth")};
  auto* hist_primary_3d {get_hist(results_file, hist_path / "hPrimary")};
  auto* hist_secondary_3d {get_hist(results_file, hist_path / "hSecondary")};

  TH1* hist_truth {hist_truth_3d};
  TH1* hist_primary {hist_primary_3d};
  TH1* hist_secondary {hist_secondary_3d};

  if (!projection.empty()) {
      hist_primary = hist_primary_3d->Project3D(projection);
      hist_secondary = hist_secondary_3d->Project3D(projection);
      hist_truth = hist_truth_3d->Project3D(projection);
  }
  ```,
  caption: [
    Snippet of the correction macro - projection.
  ],
) <lst:corr-macro-proj>


= MC closure

The main method of verifying correctness of the applied weights is to do so-called Monte Carlo closure. This is a process of comparing the reconstructed particles to the true ones, and calculating the ratio of the number of reconstructed particles to the number of true particles. The ratio is then compared to the theoretical value, which is the expected number of particles in the detector, given the efficiency of the reconstruction.

// TODO: verify simulation model
All of the datasets used for the MC closure come from PYTHIA8 model. The LHC24f3 sample uses the skimmed version of `apass7` and reflects the detector and trigger conditions seen in data from multiple periods (LHC22m/o/p/r/t). LHC24f3c focuses only on period LHC22o, with a smaller, fixed run list. LHC24f3c_fix uses the same run list as LHC24f3c but contains more data, used specifically to reach larger statistic for proton analysis. @tab:mc-closure showcases runlists for each of the datasets, corresponding to analyzed pair.

#pagebreak()

#figure(
  table(
    columns: (auto, auto, 1fr),
    align: left + horizon,
    inset: 1em,
    table.header([*Pair*], [*Dataset*], [*Run numbers*]),

    [
      $K^+ K^+$ \
      $K^+ K^-$
    ],
    [LHC24f3],
    text(size: 0.8em)[
      523397, 523399, 523401, 523441, 523541, 523559, 523671, 523677, 523728, 523731, 523779, 523783, 523786, 523788, 523789, 523792, 523797, 523821, 526463, 526465, 526466, 526467, 526468, 526486, 526505, 526512, 526525, 526526, 526528, 526559, 526596, 526606, 526612, 526639, 526641, 526643, 526647, 526649, 526713, 526714, 526715, 526716, 526719, 526720, 526776, 526860, 526865, 526886, 526938, 526963, 526964, 526966, 526967, 526968, 527015, 527016, 527028, 527031, 527033, 527034, 527038, 527039, 527041, 527057, 527076, 527108, 527109, 527228, 527237, 527240, 527259, 527260, 527261, 527262, 527345, 527347, 527349, 527446, 527518, 527523, 527690, 527694, 527731, 527734, 527736, 527821, 527825, 527826, 527828, 527848, 527850, 527852, 527863, 527864, 527865, 527869, 527871, 527895, 527898, 527899, 527902, 527963, 527976, 527978, 527979, 528021, 528026, 528036, 528093, 528094, 528097, 528105, 528107, 528109, 528110, 528231, 528232, 528233, 528263, 528266, 528292, 528294, 528316, 528319, 528328, 528329, 528330, 528332, 528336, 528347, 528359, 528379, 528381, 528386, 528448, 528451, 528461, 528463, 528530, 528531, 528534, 528537, 528543, 528602, 528604, 528617, 528781, 528782, 528783, 528784, 528798, 528801, 529077, 529078, 529084, 529088, 529115, 529116, 529117, 529128, 529208, 529209, 529210, 529211, 529235, 529237, 529242, 529248, 529252, 529270, 529306, 529317, 529320, 529324, 529338, 529341, 529450, 529452, 529454, 529458, 529460, 529461, 529462, 529542, 529552, 529554, 529662, 529663, 529664, 529674, 529675, 529690, 529691
    ],

    [
      $pi^+ pi^-$ \
      $pi^+ pi^-$
    ],
    [LHC24f3c],
    text(size: 0.8em)[
      526641, 526964, 527041, 527057, 527109, 527240, 527850, 527871, 527895, 527899, 528292, 528461, 528531
    ],

    [
      $p p$ \
      $p overline(p)$
    ],
    [LHC24f3c_fix],
    text(size: 0.8em)[
      526641, 526964, 527041, 527057, 527109, 527240, 527850, 527871, 527895, 527899, 528292, 528461, 528531
    ],
  ),
  caption: [Data used for MC closure analysis],
) <tab:mc-closure>

#pagebreak()

// TODO: Event and track selection

== Reconstruction efficiency, contamination and correction factor

Each particle type displays a distinct reconstruction efficiency and contamination factor. In the case of pions or kaons, the large data sample results in negligible secondary contamination, as seen in @fig:eff-cont. For protons, the smaller event count leads to a significant contribution in the overall sample, which correction calculations must account for.

#figure(
  pdf("../data/eff_cont.pdf", width: 100%),
  caption: [
    A comparison of the reconstruction efficiency (a) and the contamination factor (b) for different particle types.
  ],
) <fig:eff-cont>

#figure(pdf("../data/weights.pdf", width: 50%), caption: [
  Comparison of the weights for different particle types.
]) <fig:weights>

== $p p$ collisions

#figure(pdf("../data/LHC24f3c_fix/p-p/mc_closure_ratio_1d.pdf"), caption: [
  MC closure in 1D for proton-proton collisions.
]) <fig:closure-p-p-1>

#figure(pdf("../data/LHC24f3c_fix/p-p/mc_closure_ratio_2d.pdf"), caption: [
  MC closure in 2D for proton-proton collisions.
]) <fig:closure-p-p-2>

== $p overline(p)$ collisions

#figure(pdf("../data/LHC24f3c_fix/p-ap/mc_closure_ratio_1d.pdf"), caption: [
  MC closure in 1D for proton anti-proton collisions.
]) <fig:closure-p-ap-1>

#figure(pdf("../data/LHC24f3c_fix/p-ap/mc_closure_ratio_2d.pdf"), caption: [
  MC closure in 2D for proton anti-proton collisions.
]) <fig:closure-p-ap-2>

== $K^+ K^+$ collisions

#figure(pdf("../data/LHC24f3/k-k/mc_closure_ratio_1d.pdf"), caption: [
  MC closure in 1D for kaon+ kaon+ collisions.
]) <fig:closure-k-k-1>

#figure(pdf("../data/LHC24f3/k-k/mc_closure_ratio_2d.pdf"), caption: [
  MC closure in 2D for kaon+ kaon+ collisions.
]) <fig:closure-k-k-2>

== $K^+ K^-$ collisions

#figure(pdf("../data/LHC24f3/k-ak/mc_closure_ratio_1d.pdf"), caption: [
  MC closure in 1D for kaon+ kaon- collisions.
]) <fig:closure-k-ak-1>

#figure(pdf("../data/LHC24f3/k-ak/mc_closure_ratio_2d.pdf"), caption: [
  MC closure in 2D for kaon+ kaon- collisions.
]) <fig:closure-k-ak-2>

== $pi^+ pi^+$ collisions

#figure(pdf("../data/LHC24f3c/pi-pi/mc_closure_ratio_1d.pdf"), caption: [
  MC closure in 1D for pion+ pion+ collisions.
]) <fig:closure-pi-pi-1>

#figure(pdf("../data/LHC24f3c/pi-pi/mc_closure_ratio_2d.pdf"), caption: [
  MC closure in 2D for pion+ pion+ collisions.
]) <fig:closure-pi-pi-2>

== $pi^+ pi^-$ collisions

#figure(pdf("../data/LHC24f3c/pi-api/mc_closure_ratio_1d.pdf"), caption: [
  MC closure in 1D for pion+ pion- collisions.
]) <fig:closure-pi-api-1>

#figure(pdf("../data/LHC24f3c/pi-api/mc_closure_ratio_2d.pdf"), caption: [
  MC closure in 2D for pion+ pion- collisions.
]) <fig:closure-pi-api-2>


== Efficiency influence in 1d vs. 2d

#figure(
  pdf("../data/chisq_test.pdf", width: 90%),
  caption: [
    Comparison of the chi-squared values for truth vs. 1D and truth vs. 2D corrections.
  ],
) <fig:chisq-comparison>


= Correction on real data

#clearpage()

#page-without-numbering(title: "Bibliography")[
  #bibliography("main.bib", title: none)
]

#clearpage()

#page-without-numbering(title: "List of Figures")[
  #outline(title: none, target: figure)
]
