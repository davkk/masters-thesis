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

This thesis aims to improve the precision of particle physics analyses by correcting studied observable with the reconstruction efficiency of particle tracks in the ALICE detector. Specifically, it proposes and validates a new semi-automated method for applying these corrections to angular correlation functions within the upgraded Run 3 $"O"^2$ software framework.

== LHC and Run 3

The *Large Hadron Collider* (LHC), located at the European Organization for Nuclear Research (CERN) near Geneva, Switzerland, stands as the world's largest particle accelerator. Created in 2008, it accelerates and collides particles, primarily protons and heavy ions (e.g., lead). These collisions produce a variety of subatomic particles, allowing us to test predictions of the Standard Model and search for new phenomena beyond it.

The collider has completed two successful periods of data collection, the first Run 1 (2010--2013), and the other Run 2 (2015--2018). The current operational phase, *Run 3*, began in 2022 following the second, long shutdown (LS2) @lhc-upgrade. After numerous upgrades, the LHC now features proton-proton collisions at a center-of-mass energy of 13.6 [TeV], an increase from the 13 [TeV] utilized in Run 2. This higher energy helps in further studies and improves measurement precision and analysis statistics.


== The ALICE experiment

The acronym ALICE stands for *A Large Ion Collider Experiment* @collaboration2008alice, one of four major experiments at the LHC. The detector enables the study of the quark-gluon plasma (QGP), a state with conditions resembling those a few millionths of a second after the Big Bang, before quarks and gluons combined to form protons and neutrons @qgp. Heavy ion nucleus-nucleus collisions can produce such a state. In the case of ALICE, the focus lies on lead-lead (Pb-Pb) collisions. The experiment also includes proton-nucleus collisions, as well as analysis of proton-proton collisions as reference data.

== Two-particle angular correlation function

The function measures how often particle pairs appear with a given difference in pseudorapidity ($Delta eta$) and azimuthal angle ($Delta phi$). It helps to study patterns in particle production by comparing signal distributions to reference, e.g. background distribution.

=== Pseudorapidity and azimuthal angle

One can construct the angular correlation function using two quantities: pseudorapidity, $eta$, and azimuthal angle, $phi$. Both represent different aspects of a particle's trajectory in the detector.

#figure(image("img/detector-angles.png", width: 80%), caption: [
  Showcase of the angles considered in angular correlation function analysis.
]) <fig:detector-angles>

First, the pseudorapidity, $eta$, relates to the angle between the particle momentum $p$ and the beam axis ($theta$, @fig:detector-angles) as
$
  eta = -ln [tan(theta/2)].
$

The azimuthal angle on the other hand represents the angle between the $x$-axis and the projection, $p_T$, of the momentum vector onto the $x y$-plane ($phi$, @fig:detector-angles).

However, the analysis of two-particle correlation accounts for the differences between both angles, expressed as $Delta eta = eta_1 - eta_2$ and $Delta phi = phi_1 - phi_2$.

=== Angular correlation function

To construct the $Delta eta Delta phi$ correlation function, one first obtains the so-called *signal distribution*, $S(Delta eta, Delta phi)$, by pairing particles passing selection criteria, all within the same event.

Next, through the event mixing, in which pairs consist of particles from different events, one can calculate the *background distribution*, $B(Delta eta, Delta phi)$. This aids in eliminating any single-particle effects.

// TODO: write more why?

As the last step, one should normalize both distributions normalized by the corresponding numbers of pairs in the signal distribution, $N_"same"$, and background distribution, $N_"mixed"$, respectively.

Finally, the formula for the angular correlation function takes the form
$
  C(Delta eta, Delta phi) = S(Delta eta, Delta phi) / B(Delta eta, Delta phi) N_"mixed" / N_"same".
$

== Correction procedure

The correction procedure aims to mitigate biases, that arise during the actual experiment.

Correction weights come from data produced in Monte Carlo (MC) simulations. Generated collisions follow set parameters, producing particles referred to as *MC truth*. These particles originate directly from the event generator and remain unaffected by detector effects.

To model how these particles would appear in the detector, their trajectories pass through a transport package — in this case, GEANT4 @agostinelli2003geant4 — which emulates their interactions with the detector. This step accounts for e.g. energy loss, multiple scattering, and secondary particle production. Such tracks undergo reconstruction, simulating the one used for real collision data. The resulting tracks correspond to the same MC truth particles but now also include effects introduced by detector geometry and material. This final set forms the *MC reconstructed* sample.

#pagebreak()

=== Reconstruction efficiency

Calculation of reconstruction efficiency involves taking the ratio of the number of reconstructed particles to the number of simulated (true) particles
$
  epsilon = N_"recon." / N_"truth".
$ <eq:efficiency>

#figure(image("img/efficiency.png", width: 60%), caption: [
  Tracks of simulated and reconstructed particles. Successful
  identification shown in green.
]) <fig:reco-truth-tracks>

=== Secondary contamination

Ensuring the correct results in the efficiency calculations requires consideration of only the primary particles. The secondary contamination, $C$, described as the ratio of the number of secondary particles over all recorded particles, can affect the efficiency results. By taking it into account, one ensures that the final weights base only on the primary particles and not byproducts of other events.

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

As shown in @fig:contamination-proton, contamination for protons exceeds that of pions. This difference results from the lower number of protons in the data sample, most prominently in the lower range of transverse momentum.

The contamination includes contributions from both secondary particles and particles produced through interactions with detector material. In this work, both sources contribute to the contamination factor used for corrections.

// TODO: talk about why there is more material for protons?

#pagebreak()

=== Efficiency correction weights

Having calculated the efficiency histogram and secondary contamination, one can calculate the weights as
$
  w = (1 - C) / epsilon.
$

The values of $C$ and $epsilon$ typically come from histograms binned in transverse momentum ($p_T$) or in two dimensions as a function of both $p_T$ and pseudorapidity ($eta$), enabling a more accurate study of the efficiency and efficiency corrections.


= Extending FemtoUniverse in the O2Physics framework

== Framework — O2 and O2Physics

The major upgrade during Long Shutdown 2, introduced a new computing system called *Online-Offline (O2)* @o2-technical-design-report. This system replaces the previous data processing model with a more efficient approach that minimizes data volume through online track reconstruction. To support this, ALICE deployed two specialized computing farms: the First Level Processor (FLP) farm in Counting Room 1 (CR1) and the Event Processing Node (EPN) farm in Counting Room 0 (CR0). The FLP farm first reduces raw detector data from 1.1 TB/s to 900 GB/s by performing initial data suppression before sending it via Infiniband to the EPN farm. There, the first reconstruction pass further reduces the data to 90 GB/s, which then gets written to permanent storage.

The O2 framework @o2-framework introduces an entirely new software ecosystem, designed from scratch to support this architecture, by handling detector readout, data quality control, and operational services. *O2Physics* on the other hand acts as the complementary part to O2 for the LHC data analysis. It provides a way to define and run analysis tasks, which then get executed in parallel on the cluster. Designed with flexibility and extendibility in mind, the framework allows physicists to add their own analyses and modify existing ones.

Our group at Warsaw University of Technology develops a part of the analysis framework, through *FemtoUniverse* package, located in PWGCF directory @femtouniverse.

Illustrated in @fig:o2-flow, the flow of data processing in FemtoUniverse starts with a specialized task called a producer. It parses the data into tables with a well-defined structure named *FemtoDerived*, used widely by the FemtoUniverse, as well as FemtoDream packages. After preprocessing, the analysis tasks run against the tables, generating visualizations in form of histograms and other plot types.

#figure(image("img/o2-flow.png", width: 90%), caption: [
  The data flow in O2Physics.
]) <fig:o2-flow>

== The old approach for efficiency correction

Until now, the O2Physics framework has lacked a universal and automated implementation of the reconstruction efficiency correction. The older framework for Run 2 included it, however as in the recent Run 3, individual analysis tasks in the new software either have not applied the correction or have implemented it in an isolated, highly specific way.

To calculate efficiency, the O2Physics framework relied on the `femtoUniverseEfficiencyBase.cxx` task. Since each task contains its own separate set of configurable parameters, this approach required manually synchronizing the efficiency task with the main analysis task. Such an error-prone and time-consuming process demanded a careful mirroring of every change across all analyses. The introduction of any potential inconsistencies could consequently reduce the reliability of the final results.

Therefore, a large part of this work revolves around developing a generic method in O2Physics, so that the application of the corrections can be easily added to any analysis task.

== The initial idea

A key aspect of the Run 3 upgrade involved shifting to a triggerless readout system, which requires real-time lossy data compression. Traditionally, systems have executed certain data processing tasks offline, but the new system integrates them directly into the front end of data acquisition. To facilitate this transition, ALICE introduced a centralized system called Calibration and Conditions Data base (CCDB) @ccdb-alice-run3. As its main design goal, it stores and retrieves the calibration data and ensures real-time propagation of updates to the online cluster while asynchronously synchronizing content with Grid storage for later access. Researchers can retrieve the data through a REST API or a ROOT-based @root C++ client, which integrates directly with the O2 and O2Physics frameworks.

The goal of the new approach for correction builds on the idea of using the CCDB to store and retrieve the correction data efficiently. The O2 framework provides a programmatic interface to the service, which makes the process easy to integrate for own needs. With this, analysis tasks can access correction factors from a central place, ensuring consistency.

After many attempts to implement the corrections application in the O2Physics framework, the new approach would replace task-specific solutions with a single, reusable method. This effort led to the creation of a class, `FemtoUniverseEfficiencyCorrection.h`, which serves as an abstraction for other analysis tasks to use.

My first solution (@fig:workflow-initial) leveraged the O2 framework's so-called callback service, which allows any task to register a callback function that would execute custom code on special dispatched events, e.g. `Start`, `Stop`, `EndOfStream`, etc. The `CallbackService.h` file lists all the available event IDs @callback-service. I have settled for `Stop` event (@lst:callback-service-code), on which a callback uploaded the calculated correction factors to the CCDB only once, at the end of the analysis task execution. It used the `CCDBApi::storeAsTFileAny` method to interact with the CCDB @ccdbapi-store. This flow has worked as expected when running locally.

#figure(image("img/workflow-initial.png", width: 80%), caption: [
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

The *WLCG*, simply referred to as _Grid_, constitutes a global collaboration of approximately 170 computing centers across more than 40 countries. This computing infrastructure integrates around 1.4 million computer cores and 1.5 exabytes of storage. Its primary objective involves storing, distributing, and analyzing the substantial amounts of data generated annually by the LHC at CERN.

Therefore, when running the task on the Grid, the system splits a given dataset into smaller chunks, processes each in parallel on individual nodes (machines), and eventually merges the results. This aspect causes the custom callback to execute as many times as the number of jobs created.

== The new workflow for efficiency correction

The initial ideas for the correction procedure proved unusable at such large scale. I changed the workflow direction to accommodate the Grid's parallel nature. Unfortunately, I did not achieve full automation, but I have integrated key features that allow for flexibility (@fig:workflow-temp).

#figure(image("img/workflow-temp.png", width: 100%), caption: [
  Visualization of the next workflow idea for efficiency correction.
]) <fig:workflow-temp>

The first step requires generating a histogram of reconstruction efficiency weights for the desired particle type. For this, I have created a ROOT macro that acts as an initial utility for the rest of the flow. The macro retrieves the required histograms from a results file that Grid generated at the end of a run. Once it gets the data, it calculates the ratio bin-by-bin (@lst:corr-macro-eff), between reconstructed and truth histograms to calculate the efficiency as stated in the formula @eq:efficiency.

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

Each particle type shows a distinct reconstruction efficiency and contamination factor. In the case of kaons, secondary contamination remains negligible. For pions, contamination stays low but nonzero, as shown in @fig:eff-cont. Protons, on the other hand, exhibit a more significant contribution from secondary contamination, which correction calculations must account for.

#figure(
  pdf("../data/eff_cont_1d.pdf", width: 100%),
  caption: [
    A comparison of the reconstruction efficiency (a) and the contamination factor (b) for different particle types.\
    The statistical errors appear smaller than the plotted points.
  ],
) <fig:eff-cont>

The macro then computes the final weights by combining the efficiency and secondary contamination distributions to write the resulting histograms into a new ROOT file (@lst:corr-macro-weig).

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

As the next major step, one needs to upload correction weights histogram to the CCDB, in a form of ROOT object file. The O2 developer environment (`alienv`) comes with a helpful tool called `o2-ccdb-upload` that abstracts all the details from the user, and allows to easily add any ROOT file to the CCDB. The @lst:ccdb-upload-cmd contains an exemplary usage of the tool for the case of the correction weights histogram.

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

The core of this solution is `FemtoUniverseEfficiencyCorrection` class @efficiency-correction-class, that extends analysis tasks within the O2Physics framework, and allows for querying for the uploaded files, through the same interface as in the initial idea (@lst:callback-service-code). Additionally, the class utilizes configurable parameters to determine whether to apply corrections, specify the CCDB URL and histogram paths and timestamps for histogram objects retrieval.

Finally, the histograms uploaded to the CCDB look as in @fig:weights.

#figure(pdf("../data/weights.pdf", width: 69%), caption: [
  Comparison of the weights for different particle types.\
  The statistical errors appear smaller than the plotted points.
]) <fig:weights>


== Extending corrections beyond 1D - the final solution

As the final development step, we wanted to generalize the correction procedure. Hence, I opted to expand it beyond a single dimension ($p_T$ axis) to support two‐ and three‐dimensional correction weights by filling 3D histograms with variables such as $p_T$, $eta$ and event centrality (or multiplicity). This approach unifies the calculation of reconstruction efficiency, secondary contamination and final weights across any combination of the variables.

When the user specifies a projection through a flag, the macro calls ROOT's `Project3D()` method to collapse the third axis into a 1D or 2D distribution (@lst:corr-macro-proj).

The rest of the correction macro, along with the remaining steps of the correction procedure, follow the same structure as the previous workflow.

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

@fig:eff-cont-pi-2d, @fig:eff-cont-k-2d and @fig:eff-cont-p-2d show projections from constructed 3D histograms onto $p_T$ vs. $eta$ axis of the reconstruction efficiency and contamination.

#figure(
  pdf("../data/LHC24f3c/effcor/pi/eff_cont_2d.pdf"),
  caption: [
    Efficiency (a) and secondary contamination (b) in two dimensions for pion+ pion+.
  ],
) <fig:eff-cont-pi-2d>

#figure(
  pdf("../data/LHC24f3c/effcor/k/eff_cont_2d.pdf"),
  caption: [
    Efficiency (a) and secondary contamination (b) in two dimensions for kaon+ kaon+.
  ],
) <fig:eff-cont-k-2d>

#figure(
  pdf("../data/LHC24f3c_fix/effcor/p/eff_cont_2d.pdf"),
  caption: [
    Efficiency (a) and secondary contamination (b) in two dimensions for proton-proton.
  ],
) <fig:eff-cont-p-2d>


= MC closure

The standard method for verifying the applied weights is through a Monte Carlo closure test. It compares the MC reconstructed sample - after applying efficiency corrections - with the MC truth sample. In a successful closure test, the corrected reconstructed distribution matches the one coming from MC truth, within statistical uncertainties.

All datasets used for the MC closure test come from simulations based on the PYTHIA8 model [@pythia8]. The dataset names refer to labels internal to ALICE. The `LHC24f3c` and `LHC24f3c_fix` datasets focus on `apass7` of 13.6 [TeV] pp `LHC22o` data period, and share the same run lists. However, the `LHC24f3c_fix` contains more events, selected to improve statistical precision in the proton analysis. @tab:mc-closure lists the run lists used in each dataset, matched to the corresponding particle pair analyses.

// TODO: add how many events in dataset?

#figure(
  table(
    columns: (auto, auto, 1fr),
    align: horizon,
    inset: 1em,
    table.header([*Pair*], [*Dataset*], [*Run numbers*]),

    [
      $pi^+ pi^-$ \
      $pi^+ pi^-$ \
      $K^+ K^+$ \
      $K^+ K^-$ \
    ],
    [
      `LHC24f3c` \
      (size: 23.8 TB)
    ],
    table.cell(rowspan: 2)[
      526641, 526964, 527041, 527057, 527109,\ 527240, 527850, 527871, 527895, 527899,\ 528292, 528461, 528531
    ],

    [
      $p p$ \
      $p overline(p)$
    ],
    [
      `LHC24f3c_fix` \
      (size: 238.0 TB)
    ],
  ),
  caption: [Data used for MC closure analysis],
) <tab:mc-closure>

// TODO: Event and track selection

In the following figures, the top panels compare truth results to reconstructed distributions, both without corrections and with 1D or 2D efficiency corrections. The bottom panels display the ratio between each corrected result and the truth.

== Correlation functions for pions

#figure(
  pdf("../data/LHC24f3c/pi-pi/mc_closure_ratio.pdf", width: 90%),
  caption: [
    MC closure in 1D and 2D for pion+ pion+ from proton-proton collisions.
  ],
) <fig:closure-pi-pi>

The uncorrected distributions show noticeable differences from the truth, particularly in $Delta phi$ projection. Using efficiency corrections makes the reconstructed results closer to truth. In the $Delta phi$ projection, both correction methods recover the main features with almost perfect agreement.

The $Delta eta$ projection shows a different trend: at $|Delta eta| > 1$, the corrected points rise above the truth, forming a wing-like structure. This feature appears in both 1D and 2D corrections and does not reflect any known physical effect.

The same wing-like structure is visible in pions of opposite charges (@fig:closure-pi-api).

#figure(
  pdf("../data/LHC24f3c/pi-api/mc_closure_ratio.pdf", width: 90%),
  caption: [
    MC closure in 1D and 2D for pion+ pion- from proton-proton collisions.
  ],
) <fig:closure-pi-api>


// TODO: We still don't know what caused it, and we need to do more research.

== Correlation functions for kaons

In @fig:closure-k-ak, the $C(Delta eta)$ plot presents the clearest distinction -- among all studied particle pairs -- between the effects of 1D and 2D corrections. The uncorrected bins deviate the most from the truth. However, the more dimensions in the corrections, the better agreement with the reference distribution, especially at $0.7 < |Delta eta| < 1.5$.

#figure(pdf("../data/LHC24f3c/k-k/mc_closure_ratio.pdf", width: 90%), caption: [
  MC closure in 1D and 2D for kaon+ kaon+ from proton-proton collisions.
]) <fig:closure-k-k>

#figure(
  pdf("../data/LHC24f3c/k-ak/mc_closure_ratio.pdf", width: 90%),
  caption: [
    MC closure in 1D and 2D for kaon+ kaon- from proton-proton collisions.
  ],
) <fig:closure-k-ak>

#pagebreak()

== Correlation functions for protons

As the final particle pair analyzed, protons show negligible differences in effects from 1D vs. 2D corrections.

#figure(
  pdf("../data/LHC24f3c_fix/p-p/mc_closure_ratio.pdf", width: 90%),
  caption: [
    MC closure in 1D and 2D for proton-proton from proton-proton collisions.
  ],
) <fig:closure-p-p>

#figure(
  pdf("../data/LHC24f3c_fix/p-ap/mc_closure_ratio.pdf", width: 90%),
  caption: [
    MC closure in 1D and 2D for proton anti-proton from proton-proton collisions.
  ],
) <fig:closure-p-ap>

#pagebreak()

== Efficiency influence in 1D vs. 2D

To quantify the influence of efficiency corrections, I have computed the unweighted $chi^2$ values between the MC truth and the corrected correlation functions. For both 1D and 2D corrections, I have compared the resulting angular correlation functions using ROOT's `Chi2Test` method. As shown in @fig:chisq-comparison, the results suggest a consistent improvement in corrected functions when applying for two dimensions, across all analyzed particle pairs.

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
