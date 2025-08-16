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
#show figure: set block(inset: (top: 0.5em, bottom: 0.6em))
#show figure.caption: set text(size: 0.8em)

#set table(inset: (x: 0.5em, y: 0.3em))

#show heading.where(level: 1): it => {
  let num = counter(heading).at(here()).first()
  set text(24pt, weight: "bold")
  set par(justify: false)

  pagebreak(to: "odd", weak: false)

  v(1em)

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
  text(size: 2.2em, weight: "bold")[#title]
  v(3em)
  body
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
      in the field of study Applied Physics \
      and specialization Data Exploration and Interdisciplinary Modelling
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

This thesis introduces a new, semi-automated workflow for the ALICE experiment's Run 3 O2Physics framework, specifically within the `FemtoUniverse` package. The workflow lets anyone extend existing analysis tasks with calculation of reconstruction efficiency and application of correction weights to angular correlation functions. It replaces earlier ad-hoc solutions with a reusable and less error-prone approach.

The first step involves using a ROOT macro to derive correction weights from Monte Carlo simulations, taking into account both reconstruction efficiency and secondary particle contamination. The user can then upload these weights to the ALICE Calibration and Conditions Database (CCDB) for later use. A custom `FemtoUniverseEfficiencyCorrection` class, integrated into given analysis task, fetches and applies them as angular correlation function corrections.

A Monte Carlo closure test confirmed the workflow's validity. Moreover, based on analyzed pairs of pions, kaons and protons, the two-dimensional corrections improved agreement with truth data, more than their one-dimensional variant. A chi-squared analysis supported the findings quantitatively.

Finally, applying the workflow to real collision data produced promising results, yielding similar correction effects to those observed with MC data.

#v(2em)
_Keywords:_ ALICE, Run 3, O2Physics, angular correlation functions, reconstruction efficiency, efficiency correction, femtoscopy.

#v(1fr)
#stack(dir: ltr, spacing: 1fr, "supervisor's signature", "student's signature")

#clearpage()

#text(size: 1.3em)[Streszczenie]
#hr

*Tytuł pracy:* #thesis-title-pl
#v(1em)

W pracy przedstawiono nowy, częściowo automatyczny proces liczenia wydajności rekonstrukcji i na jej podstawie,  nakładania poprawek na kątowe funkcje korelacyjne. Proces ten został dodany do oprogramowania O2Physics, konkretnie w katalogu `FemtoUniverse`, powstałego w ramach Run 3 w eksperymencie ALICE. Każdy korzystający z oprogramowania może rozszerzyć istniejące skrypty do analizy danych o te funkcjonalności. Proces tym samym zastępuje wcześniejsze rozwiązania ad-hoc ogólnym, mniej podatnym na błędy podejściem.

System wykorzystuje tzw. makro napisane za pomocą oprogramowania ROOT do uzyskania wag z symulacji Monte Carlo, biorąc pod uwagę zarówno wydajność rekonstrukcji, jak i zanieczyszczenie cząstkami wtórnymi. Użytkownik może następnie dodać te wagi do specjalnej bazy danych _Calibration and Conditions Database_ (CCDB). Tak przygotowane wagi używane są później przez stworzoną klasę `FemtoUniverseEfficiencyCorrection`, która pobiera i stosuje je jako poprawki do kątowych funkcji korelacyjnych.

Test _Monte Carlo closure_ potwierdził poprawność całego procesu korekcji. Ponadto, na podstawie analizowanych par pionów, kaonów i protonów, korekty dwuwymiarowe najlepiej poprawiły zgodność z danymi MC truth. Analiza chi-kwadrat pozwoliła na liczbowe potwierdzenie porównania korekcji między 1D a 2D.

Ostatecznie, zastosowanie poprawek na danych z rzeczywistych zderzeń dało obiecujące wyniki, powodując zbliżony wpływ na funkcje korelacyjne do tych obserwowanych w korekcjach dla danych MC.

#v(2em)
_Słowa kluczowe:_ ALICE, Run 3, O2Physics, kątowe funkcje korelacyjne, wydajność rekonstrukcji, poprawka na wydajność, femtoskopia.

#v(1fr)
#stack(dir: ltr, spacing: 1fr, "podpis opiekuna naukowego", "podpis studenta")

#clearpage()

#page-without-numbering(title: "Contents")[
  #outline(title: none)
]

#clearpage()

#set page(footer: context {
  let page-number = here().page()
  let even = calc.rem(page-number, 2) == 0

  rect(stroke: (top: 2pt + bg-main), width: 100%, inset: (top: 1em))[
    #align(if even { left } else { right })[
      #page-number
    ]
  ]
})

= Introduction

This thesis introduces a new approach to calculate particle reconstruction efficiency within the upgraded Run 3 $"O"^2$ software framework of the ALICE experiment. The reconstruction efficiency describes a proportion of produced and successfully reconstructed particles. The thesis applies the calculated efficiency to correct angular correlation functions. A low efficiency results in skewed measured distributions, hence the correction improves the accuracy of particle physics analyses.

== LHC and Run 3

The *Large Hadron Collider* (LHC), located at the European Organization for Nuclear Research (CERN) near Geneva, Switzerland, stands as the world's largest particle accelerator. Since 2009, it provides data from particle acceleration and collision, primarily protons and heavy ions (e.g. lead).

The collider has completed two successful periods of data collection, the first Run 1 (2010--2013), and the other Run 2 (2015--2018). The current operational phase, *Run 3*, began in 2022 following the second long shutdown (LS2) @lhc-upgrade. After numerous upgrades, the LHC now features proton-proton and lead-lead collisions at a center-of-mass energy of 13.6 TeV, an increase from the 13 TeV utilized in Run 2. The higher energy helps in further studies, as well as improves measurement precision and overall analysis.

== The ALICE experiment

The acronym ALICE stands for *A Large Ion Collider Experiment* @collaboration2008alice, one of four major experiments at the LHC. The detector enables the study of the quark-gluon plasma (QGP), a state with conditions resembling those a few millionths of a second after the Big Bang, before quarks and gluons combined to form protons and neutrons @qgp. Heavy ion nucleus-nucleus collisions can produce such a state. In the case of ALICE, the focus lies on lead-lead (Pb-Pb) collisions @alice-qcd. The experiment also studies proton-nucleus collisions, as well as analysis of proton-proton collisions as reference data.

== Two-particle angular correlation function

The function measures how often particle pairs appear for a given difference in pseudorapidity ($Delta eta$) and azimuthal angle ($Delta phi$). It helps to study patterns in particle production by comparing same-event signal distributions to mixed-event reference in order to remove distortions introduced by the detector's finite acceptance, most notably along $eta$. An ideal detector with full acceptance and perfect efficiency would not require this correction.

=== Pseudorapidity and azimuthal angle

One can construct the angular correlation function using two quantities: pseudorapidity, $eta$, and azimuthal angle, $phi$. Both represent different aspects of a particle's trajectory in the detector.

#figure(image("img/detector-angles.png", width: 80%), caption: [
  Showcase of the angles considered in angular correlation function analysis.
]) <fig:detector-angles>

First, the pseudorapidity, $eta$, relates to the angle, denoted in @fig:detector-angles as $theta$, between the particle momentum $p$ and the beam axis as
$
  eta = -ln [tan(theta/2)].
$

The azimuthal angle on the other hand represents the angle, $phi$, between the $x$-axis and the projection, $p_T$, of the momentum vector onto the $x y$-plane (@fig:detector-angles).

However, the analysis of two-particle correlation accounts for the differences between both angles, expressed as $Delta eta = eta_1 - eta_2$ and $Delta phi = phi_1 - phi_2$.

=== Angular correlation function

To construct the $Delta eta Delta phi$ correlation function, one first obtains the so-called *signal distribution*, $S(Delta eta, Delta phi)$, by pairing particles passing selection criteria, all within the same event.

Next, through the event mixing, in which pairs consist of particles from different events, one can calculate the *background distribution*, $B(Delta eta, Delta phi)$. Division of signal distribution by the mixed-event reference removes distortions caused by the detector's finite acceptance (especially in $eta$) and reveals the underlying correlation structures.

As the last step, one should normalize both distributions by the corresponding numbers of pairs in the signal distribution, $N_"same"$, and background distribution, $N_"mixed"$, respectively.

Finally, the formula for the angular correlation function takes the form
$
  C(Delta eta, Delta phi) = S(Delta eta, Delta phi) / B(Delta eta, Delta phi) N_"mixed" / N_"same".
$

== Correction procedure

This procedure aims to mitigate biases that arise during the actual experiment. Correction weights come from data produced in Monte Carlo (MC) simulations. In this context, Monte Carlo event generators (such as *PYTHIA*) model the physics of high-energy collisions. They implement theoretical frameworks of Quantum Chromodynamics (QCD) and other related models to approximate particle production in proton–proton or heavy-ion interactions. Given initial conditions like collision energy, the generator produces a list of particles that represent the expected outcome of the event. Therefore, these particles, referred to as *MC truth*, originate directly from the event generator and remain unaffected by detector effects.

To model how these particles would appear in the detector, the MC truth particles pass through a transport package -- in this case, GEANT4 @agostinelli2003geant4 -- which emulates their interactions with the detector. This simulation step accounts for e.g. energy loss, multiple scattering, and secondary particle production. Such tracks undergo reconstruction, simulating the one used for real collision data. The resulting tracks correspond to the same MC truth particles but now also include effects introduced by the detector geometry and material. This final set forms the *MC reconstructed* sample.

#pagebreak()

=== Reconstruction efficiency

Reconstruction efficiency can vary with transverse momentum, $p_T$, and pseudorapidity, $eta$. Tracks with too low $p_T$ may bend too strongly in the magnetic field and fail to register enough hits for a reliable fit (@fig:reco-truth-tracks). On the other hand, detector layout or dead zones can lower the efficiency in general. However, corrections based on reconstruction efficiency can help recover the true count of analyzed particles.

Calculation of reconstruction efficiency involves taking the ratio of the number of reconstructed particles to the number of simulated (true) particles
$
  epsilon = N_"recon." / N_"truth".
$ <eq:efficiency>

#figure(
  image("img/efficiency.png", width: 60%),
  caption: [
    Tracks of simulated and reconstructed particles. Successful identification shown in green.
  ],
) <fig:reco-truth-tracks>

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

As shown in @fig:contamination-proton, proton contamination exceeds pion contamination. This difference stems from the high proton content of the detector material, as protons often scatter out and appear as signal particles. The effect intensifies at low transverse momentum, where secondary particles from decays or material interactions dominate.

The contamination includes contributions from both secondary particles and those produced through interactions with the detector material. In this work, both sources contribute to the contamination factor used for corrections.

#pagebreak()

=== Efficiency correction weights

Having calculated the efficiency histogram and secondary contamination, one can calculate the weights as
$
  w(p_T, eta) = (1 - C(p_T, eta)) / epsilon(p_T, eta).
$

The values of $C$ and $epsilon$ typically come from histograms binned in transverse momentum ($p_T$) or in two dimensions as a function of both $p_T$ and pseudorapidity ($eta$), enabling a more accurate study of the efficiency itself and efficiency corrections.


= Extending FemtoUniverse in the O2Physics framework

== Framework — O2 and O2Physics

The major upgrade during Long Shutdown 2 introduced a new computing system called *Online-Offline (O2)* @o2-technical-design-report. This system replaces the previous data processing model with a more efficient approach that minimizes data volume through online track reconstruction. To support this, ALICE deployed two specialized computing farms: the First Level Processor (FLP) farm in Counting Room 1 (CR1) and the Event Processing Node (EPN) farm in Counting Room 0 (CR0). The FLP farm first reduces raw detector data by performing initial data compression before sending it via _Infiniband_ to the EPN farm. There, the first reconstruction pass further reduces the data, to finally save it to permanent storage.

#figure(image("img/o2-raw-data-flow.png", width: 90%), caption: [
  The data flow in the O2 framework.
]) <fig:o2-raw-data-flow>

The O2 framework @o2-framework introduces an entirely new software ecosystem, designed from scratch to support this architecture, by handling detector readout, data quality control, and operational services. *O2Physics* on the other hand acts as the complementary part to O2 for the LHC data and simulation data analysis. It provides a way to define and run analysis tasks, which then get executed on a cluster, in a distributed manner. Designed with flexibility and extendibility in mind, the framework allows physicists to add their own analyses and modify existing ones.

Our group at Warsaw University of Technology develops a part of the analysis framework, through *FemtoUniverse* package, located in PWGCF directory @femtouniverse.

Illustrated in @fig:o2-flow, the flow of data processing in FemtoUniverse starts with a specialized task called a producer. It parses the data into tables with a well-defined structure named *FemtoDerived*, used widely by the FemtoUniverse, as well as FemtoDream packages. After preprocessing, the analysis tasks run against the tables, generating visualizations in form of histograms and other plot types.

#figure(image("img/o2-flow.png", width: 90%), caption: [
  The data flow in O2Physics.
]) <fig:o2-flow>

== Worldwide LHC Computing Grid (WLCG)

The *WLCG*, simply referred to as _Grid_, constitutes a global collaboration of approximately 170 computing centers across more than 40 countries. This computing infrastructure integrates around 1.4 million computer cores and 1.5 exabytes of storage. Its primary objective involves storing, distributing, and analyzing the substantial amounts of data generated annually by the LHC at CERN.

The O2Physics framework by design can run in a distributed and parallel environment. Hence, it aligns perfectly with the Grid architecture.

== The old approach for efficiency correction

Until now, the FemtoUniverse has lacked a universal and automated implementation of the reconstruction efficiency correction. The code in older framework for Run 2 has included it. However, in the recent Run 3, individual analysis tasks in the new software either have not applied the correction or have implemented it in an isolated, highly specific way.

To calculate efficiency, the analyses done in FemtoUniverse package relied on a task called `femtoUniverseEfficiencyBase.cxx`. Since each task contains its own separate set of configurable parameters, this approach required manually synchronizing the efficiency task with the main analysis task. Such an error-prone and time-consuming process demanded a careful mirroring of every change across all configurations. The introduction of any potential inconsistencies could consequently reduce the reliability of the final results.

Therefore, a large part of this work focuses on developing a generic method in O2Physics, which allows physicists to apply the corrections easily to any analysis task.

== The initial idea

A key aspect of the Run 3 upgrade involved shifting to a triggerless readout system, which requires real-time lossy data compression. Traditionally, systems have executed certain data processing tasks offline, but the new system integrates them directly into the front end of data acquisition. To facilitate this change, ALICE introduced a centralized system called Calibration and Conditions Database (CCDB) @ccdb-alice-run3. As its main design goal, it stores and retrieves the calibration data and ensures real-time propagation of updates to the online cluster, while simultaneously synchronizing content with Grid storage for later access. Researchers can retrieve the data through a REST API or a ROOT-based @root C++ client, which integrates directly with the O2 and O2Physics frameworks.

The goal of the new approach for correction builds on the idea of using the CCDB to store and retrieve the correction data efficiently. Fortunately, the O2 framework already provides a programmatic interface to the service. This makes it easy to integrate it for own needs. Analysis tasks can then access any correction data from a central location, ensuring a single source of truth and consistency.

After many attempts to implement the corrections application in the FemtoUniverse, the new approach would replace task-specific solutions with a single, reusable method. This effort led to the creation of a class, `FemtoUniverseEfficiencyCorrection.h`, which serves as an abstraction for other analysis tasks to use.

The first solution (@fig:workflow-initial) leveraged the O2 framework's callback service. It allows any task to register a callback function that executes custom code when special events get dispatched, such as `Start`, `Stop`, `EndOfStream`. The `CallbackService.h` file lists all the available event IDs @callback-service. This implementation used the `Stop` event (@lst:callback-service-code), based on which a callback uploaded the calculated correction factors to the CCDB only once, at the end of the analysis task execution. It used the `CCDBApi::storeAsTFileAny` method to interact with the CCDB @ccdbapi-store. This flow has worked as expected when running locally.

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

However, the above idea has a major drawback. It assumes that the analysis task executes on a single machine, whereas parallel and distributed environments, such as the Worldwide LHC Computing Grid, typically involve multiple machines.

Therefore, when running the task on the Grid, the system splits a given dataset into smaller chunks, processes each in parallel on individual nodes (machines), and eventually merges the results. This aspect causes the custom callback to execute as many times as the number of jobs created.

== The new workflow for efficiency correction

The initial ideas for the correction procedure proved unusable at such large scale. As a result, the workflow had to adapt to the Grid's parallel nature. Although this solution does not achieve full automation, it integrates key features that allow for flexibility (@fig:workflow-temp).

#figure(image("img/workflow-temp.png", width: 100%), caption: [
  Visualization of the next workflow idea for efficiency correction.
]) <fig:workflow-temp>

The first step requires generating a histogram of reconstruction efficiency weights for the desired particle type. For this, a custom ROOT macro acts as an initial utility for the rest of the flow. The macro retrieves the required histograms from a results file that Grid generated at the end of a run. Once it gets the data, it calculates the ratio bin-by-bin (@lst:corr-macro-eff), between reconstructed and truth histograms to calculate the efficiency as stated in the formula @eq:efficiency.

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

Each particle type shows a distinct reconstruction efficiency and contamination factor. In the case of kaons, secondary contamination remains negligible. For pions, contamination stays low but nonzero, as shown in @fig:eff-cont. Lastly, protons exhibit a more significant contribution from secondary contamination, which correction calculations must address.

#figure(
  pdf("../data/eff_cont_1d.pdf", width: 100%),
  caption: [
    A comparison of the reconstruction efficiency (a) and the contamination factor (b) for different particle types.\
    The statistical errors appear smaller than the plotted points.
  ],
) <fig:eff-cont>

Furthermore, the reconstruction efficiency seen in the @fig:eff-cont depends strongly on the applied particle selection criteria. For instance, at $p_T = 0.7$ GeV/$c$, particle identification starts to rely on the Time-Of-Flight (TOF) detector. Due to low matching efficiency between the Time Projection Chamber (TPC) and TOF in this momentum region, the overall reconstruction efficiency drops sharply.

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

As the next major step, one needs to upload correction weights histogram to the CCDB in a form of ROOT object file. The O2's developer environment (`alienv`) comes with a helpful tool called\ `o2-ccdb-upload`, that abstracts all the details from the user, and allows to easily add any ROOT file to the CCDB. The @lst:ccdb-upload-cmd contains an exemplary usage of the tool for the case of the correction weights histogram.

#figure(
  ```bash
  o2-ccdb-upload
      --host http://alice-ccdb.cern.ch # CCDB URL
      --path Users/d/dkarpins/Correction # CCDB path
      --file ./EfficiencyCorrection.root # path to ROOT file
      --key hWeights # name of the histogram
  ```,
  caption: [
    Example command for the CCDB upload.
  ],
) <lst:ccdb-upload-cmd>

The core of this solution involves the `FemtoUniverseEfficiencyCorrection` class @efficiency-correction-class, which extends analysis tasks, and allows for querying for the uploaded files through the same interface as in the initial idea (@lst:callback-service-code). Additionally, the class works based on configurable parameters, such as whether to apply corrections or not, the CCDB URL to use, histogram paths and timestamps for histogram objects retrieval.

Finally, the histograms uploaded to the CCDB look as in @fig:weights.

#figure(pdf("../data/weights.pdf", width: 69%), caption: [
  Comparison of the weights for different particle types.\
  The statistical errors appear smaller than the plotted points.
]) <fig:weights>


== Extending corrections beyond 1D - the final solution

The final development step focused on generalizing the correction procedure. Hence, the implementation expanded beyond a single dimension ($p_T$ axis) to support two‐ and three‐dimensional correction weights by filling 3D histograms with variables such as $p_T$, $eta$ and event centrality (or multiplicity). This approach unifies the calculation of reconstruction efficiency, secondary contamination and final weights across any combination of the variables.

When the user of the workflow specifies a projection through a flag, the macro calls ROOT's `Project3D()` method to collapse the third axis into a 1D or 2D distribution (@lst:corr-macro-proj).

The rest of the correction macro, along with the remaining steps of the correction procedure follow the same structure as the previous workflow.

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

@fig:eff-cont-pi-2d, @fig:eff-cont-k-2d and @fig:eff-cont-p-2d show projections from the constructed 3D histograms onto $p_T$ vs. $eta$ axis of the reconstruction efficiency and contamination.

#figure(pdf("../data/LHC24f3c/effcor/pi/eff_cont_2d.pdf"), caption: [
  Efficiency (a) and secondary contamination (b) in two dimensions for pion.
]) <fig:eff-cont-pi-2d>

#figure(pdf("../data/LHC24f3c/effcor/k/eff_cont_2d.pdf"), caption: [
  Efficiency (a) and secondary contamination (b) in two dimensions for kaon.
]) <fig:eff-cont-k-2d>

#figure(pdf("../data/LHC24f3c_fix/effcor/p/eff_cont_2d.pdf"), caption: [
  Efficiency (a) and secondary contamination (b) in two dimensions for proton.
]) <fig:eff-cont-p-2d>


= Validation of correction workflow

This chapter focuses on the validation of the correction workflow described previously. The validation involves performing a Monte Carlo closure test, as well as a simple $chi^2$ analysis.

== Event and track selection

Events must satisfy criteria designed to reject poorly defined collisions and reduce the impact of pileup. Such issue arises when detectors register signals from multiple interactions within the same readout window. In particular, the selection includes a constraint on the primary vertex z-position, requiring $|"vtx"_z| < 10$ cm to exclude collisions occurring far from the center of the ALICE detector. There, the particle detection becomes unreliable.

The O2 framework also provides built-in event selection criterion called `sel8` (Run 3 data), based on FT0A and FT0C forward detectors used for triggering and event characterization in studied collisions. It performs pileup rejection and ensures basic event quality.

@fig:track-selection shows the chosen track selection requirements for the analysis of each pair. There exists a global track filter, also provided by the O2 framework for general use. The @fig:global-track-selection outlines its details.

#figure(
  table(
    columns: 4,
    align: left + horizon,
    table.header([*Particle pair*], [*Cuts*], [*Particle pair*], [*Cuts*]),

    [*$p p$*],
    [
      $0.5 < p_T < 6$ GeV/$c$ \
      TOF $p_T > 0.7$ GeV/$c$ \
      $N_(sigma_"TPC") < 3$ ($p_T < 0.7$ GeV/$c$)
    ],

    [*$p overline(p)$*],
    [
      $0.5 < p_T < 6$ GeV/$c$ \
      TOF $p_T > 0.7$ GeV/$c$ \
      $N_(sigma_"TPC") < 3$ ($p_T < 0.7$ GeV/$c$)
    ],

    [*$pi^+ pi^+$*],
    [
      $0.5 < p_T < 6$ GeV/$c$ \
      TOF $p_T > 0.7$ GeV/$c$ \
      $N_(sigma_"TPC") < 3$ ($p_T < 0.7$ GeV/$c$)
    ],

    [*$pi^+ pi^-$*],
    [
      $0.5 < p_T < 6$ GeV/$c$ \
      TOF $p_T > 0.7$ GeV/$c$ \
      $N_(sigma_"TPC") < 3$ ($p_T < 0.7$ GeV/$c$)
    ],

    [*$K^+ K^+$*],
    [
      $0.5 < p_T < 6$ GeV/$c$ \
      TOF $p_T > 0.7$ GeV/$c$ \
      $N_(sigma_"TPC") < 3$ ($p_T < 0.7$ GeV/$c$)
    ],

    [*$K^+ K^-$*],
    [
      $0.5 < p_T < 6$ GeV/$c$ \
      TOF $p_T > 0.7$ GeV/$c$ \
      $N_(sigma_"TPC") < 3$ ($p_T < 0.7$ GeV/$c$)
    ],
  ),
  caption: [
    Event selection criteria.
  ],
) <fig:track-selection>

#figure(
  table(
    columns: 2,
    align: left,
    table.header([*Cuts*], [*globalTrack*]),

    [min number of crossed rows TPC], [70],
    [min ratio of crossed rows over findable clusters TPC], [0.8],
    [max chi2 per cluster TPC], [4.0],
    [max chi2 per cluster ITS], [36.0],
    [require TPC refit], [true],
    [require ITS refit], [true],
    [max DCA to vertex z], [2.0],
    [max DCA to vertex xy], [0.0105 + 0.035 / p$""_T^(1.1)$],
    [cluster requirement ITS], [in 3 innermost ITS layers],

    [p$""_T$ range], [0.1 - 1e10],
    [η range], [-0.8 - 0.8],
  ),
  caption: [Partial `TrackSelection` table used in O2 framework as the global track filter @global-track-filter],
) <fig:global-track-selection>

== Monte Carlo closure test

The standard method for verifying the applied weights involves performing a Monte Carlo closure test. It compares the MC reconstructed sample (after efficiency corrections) with the MC truth sample. In a successful closure test, the corrected reconstructed distribution matches the one coming from MC truth, within statistical uncertainties.

All datasets used for the MC closure test come from simulations based on the PYTHIA8 model @pythia8. The dataset names refer to labels internal to ALICE. The `LHC24f3c` and `LHC24f3c_fix` datasets focus on `apass7` of 13.6 TeV pp `LHC22o` data period, and share the same run lists. However, the `LHC24f3c_fix` contains more events, selected to improve statistical precision in the proton pairs analysis. @tab:mc-closure shows the run lists used in each dataset, matched to the corresponding particle pair analyses.

// TODO: add how many events in dataset?

#figure(
  table(
    columns: (auto, auto, 1fr),
    align: horizon,
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


== Correlation functions for pions

In the following figures, the top panels compare truth results to reconstructed distributions, both without corrections and with 1D or 2D efficiency corrections. The bottom panels display the ratio between each corrected result and the truth.

The uncorrected distributions in @fig:closure-pi-pi show noticeable differences from the truth, particularly in $Delta eta$ projection. Using efficiency corrections improves the agreement between reconstructed results and the truth. In the $Delta phi$ projection, both correction dimensions reproduce the overall shape of the correlation function, though systematic deviations of up to 2% persist.

#figure(pdf("../data/LHC24f3c/pi-pi/data_correction.pdf"), caption: [
  MC closure in 1D and 2D for pion+ pion+ from $p p$ collisions MC data.
]) <fig:closure-pi-pi>

The $Delta eta$ projection shows a different trend: at $|Delta eta| > 1$, the corrected points rise above the truth. Previous analyses of mixed‑event corrections show that finite binning in event multiplicity and primary vertex (PV) position can create a mismatch in the background shape at large $eta$ differences, forming a wing-like structure @wings. This artifact appears in both 1D and 2D corrections. Nevertheless, the deviation from the truth in the 2D projection remains smaller compared to the 1D case.

The opposite-sign pion correlation shown in @fig:closure-pi-api exhibits similar features to the like-sign case - the corrected distributions closely follow the MC truth across most of the $Delta phi$ and $Delta eta$ ranges. As before, 2D corrections yield better agreement with the truth than 1D corrections. A wing-like structure again emerges at $|Delta eta| > 1$, indicating the same artifact discussed earlier.

#figure(pdf("../data/LHC24f3c/pi-api/data_correction.pdf"), caption: [
  MC closure in 1D and 2D for pion+ pion- from $p p$ collisions MC data.
]) <fig:closure-pi-api>

== Correlation functions for kaons

The $C(Delta eta)$ plots for kaon pairs with like (@fig:closure-k-k) and unlike signs (@fig:closure-k-ak) present the clearest distinction (among all studied particle pairs) between the effects of 1D and 2D corrections. The uncorrected bins deviate the most from the truth. However, the more dimensions in the corrections, the better agreement with the reference distribution. After applying the 2D corrections, the ratio of reconstructed to true deviates by no more than 2%.

#figure(pdf("../data/LHC24f3c/k-k/data_correction.pdf"), caption: [
  MC closure in 1D and 2D for kaon+ kaon+ from $p p$ collisions MC data.
]) <fig:closure-k-k>

#figure(pdf("../data/LHC24f3c/k-ak/data_correction.pdf"), caption: [
  MC closure in 1D and 2D for kaon+ kaon- from $p p$ collisions MC data.
]) <fig:closure-k-ak>

== Correlation functions for protons

When looking at the $Delta eta$ projections for proton-proton pair (@fig:closure-p-p), one could draw a conclusion, that the corrections from 1D yield better results compared to 2D. However, chi-squared test results, shown in the next section, provide more accurate insight regarding the difference.

#figure(pdf("../data/LHC24f3c_fix/p-p/data_correction.pdf"), caption: [
  MC closure in 1D and 2D for proton-proton from $p p$ collisions MC data.
]) <fig:closure-p-p>

The proton anti-proton pair (@fig:closure-p-ap) effectively shows no significant differences in effects between 1D vs. 2D corrections in $Delta phi$ projections, with only a slight deviation for $|Delta eta| > 0.7$.

#figure(pdf("../data/LHC24f3c_fix/p-ap/data_correction.pdf"), caption: [
  MC closure in 1D and 2D for proton anti-proton from $p p$ collisions MC data.
]) <fig:closure-p-ap>

== Efficiency influence for $p_T$-only vs. $p_T$ and $eta$

This section quantifies the influence of efficiency corrections by comparing the unweighted $chi^2$ values between the MC truth and the corrected correlation functions. The comparison relies on ROOT's `Chi2Test` method, which calculates the chi-squared per degree of freedom ($chi^2 / "NDF"$) to provide a statistical measure of the goodness of fit between two histograms. A lower value typically indicates a better agreement. The test compares the full two-dimensional correlation function from the MC truth sample against the uncorrected, 1D-corrected, and 2D-corrected reconstructed distributions.

#figure(
  pdf("../data/chisq_test.pdf", width: 90%),
  caption: [
    Comparison of the chi-squared values for truth vs. no corrections, truth vs. 1D and truth vs. 2D corrections.
  ],
) <fig:chisq-comparison>

As shown in @fig:chisq-comparison, the results demonstrate a consistent and significant improvement when applying two-dimensional corrections. For every particle pair analyzed, the $chi^2 / "NDF"$ value reaches its minimum for the 2D-corrected data. This provides a quantitative evidence that this method improves the correspondence of the reconstructed data with the MC truth.


= Correction on real data

The following figures show the correlation functions for real data before and after applying 1D and 2D efficiency corrections. Each of the two panels compare the uncorrected distributions with the corrected ones.

In addition, the next figures also visualize the same correlation functions using 3D surface plots. Left plot shows the uncorrected correlation function. Upper and lower plots in the middle column display the results after 1D and 2D corrections, respectively. The right column contains two-dimensional ratio plots, which show the bin-by-bin ratio of each corrected distribution to the uncorrected one.

== Correlation functions for pions

Corrections on pion+ pion+ pair (@fig:data-pi-pi) seem to slightly lower the correlation peak at $Delta phi = 0$ (same jet effects) up to 2%. They also increase the effects from momentum conservation at $Delta phi > 2$ by less than 2%. For the $Delta eta$ projection, the corrections do not affect the function shape too much, with visible differences in the ranges $|Delta eta| > 0.7$, where the deviations reach 2%.

#figure(
  pdf("../data/LHC22o_pass7_minBias_small/pi-pi/data_correction.pdf"),
  caption: [
    Data in 1D and 2D for pion+ pion+ from real data ($p p$ collisions).
  ],
) <fig:data-pi-pi>

When comparing the ratios for 1D and 2D corrections (@fig:data-pi-pi-3d), one can see that 2D corrections have introduced localized regions of higher deviation in the ratio for $0.5 < Delta phi < 1$ and\ $2 < Delta phi < 3$ ranges.

#figure(
  pdf("../data/LHC22o_pass7_minBias_small/pi-pi/corr_func_compare.pdf"),
  caption: [
    Correlation function for pion+ pion+.
  ],
) <fig:data-pi-pi-3d>

For the $pi^+ pi^-$ pair, the corrections noticeably alter the correlation function's shape. At the same jet peak near $Delta phi = 0$, the corrected distributions show an increase of up to 10%. For larger variable differences, both 1D and 2D corrections reduce the function's values.

#figure(
  pdf("../data/LHC22o_pass7_minBias_small/pi-api/data_correction.pdf"),
  caption: [
    Data in 1D and 2D for pion+ pion-.
  ],
) <fig:data-pi-api>

In @fig:data-pi-api-3d, one can see that the values around the peak do not change much after correction, and the areas away from the peak deviate by less than 5% from the uncorrected function.

#figure(
  pdf("../data/LHC22o_pass7_minBias_small/pi-api/corr_func_compare.pdf"),
  caption: [
    Correlation function for pion+ pion- from real data ($p p$ collisions).
  ],
) <fig:data-pi-api-3d>

== Correlation functions for kaons

In @fig:data-k-k, the results in the $Delta phi$ projection do not show any significant differences between the uncorrected and corrected distributions. However, the $Delta eta$ projection shows a significant difference in the correction effects between 1D and 2D for $|Delta eta| > 0.7$.

#figure(
  pdf("../data/LHC22o_pass7_minBias_small/k-k/data_correction.pdf"),
  caption: [
    Data in 1D and 2D for kaon+ kaon+.
  ],
) <fig:data-k-k>

In @fig:data-k-k-3d, the 1D corrections seem to increase the values in the areas related to back-to-back jets by \<3%, when looking at $Delta phi > 2$ region. In contrast, the 2D corrections decrease them by 3%. One can also see 2D corrections seem to magnify the resonance effects in the function.

#figure(
  pdf("../data/LHC22o_pass7_minBias_small/k-k/corr_func_compare.pdf"),
  caption: [
    Correlation function for kaon+ kaon+ from real data ($p p$ collisions).
  ],
) <fig:data-k-k-3d>

For the opposite-sign kaon+ kaon- pair (@fig:data-k-ak, @fig:data-k-ak-3d), the corrections primarily affect the same jet peak, with other areas unchanged. Both 1D and 2D corrections increase the peak by less than 5%.

#figure(
  pdf("../data/LHC22o_pass7_minBias_small/k-ak/data_correction.pdf"),
  caption: [
    Data in 1D and 2D for kaon+ kaon-.
  ],
) <fig:data-k-ak>

#figure(
  pdf("../data/LHC22o_pass7_minBias_small/k-ak/corr_func_compare.pdf"),
  caption: [
    Correlation function for kaon+ kaon- from real data ($p p$ collisions).
  ],
) <fig:data-k-ak-3d>

== Correlation functions for protons

Wing-like structures observed in the $Delta eta$ projection for the MC closure test (@fig:closure-p-p) also appear in the real data results (@fig:data-p-p). Both 1D and 2D corrections reduce the wing artifacts, with 2D corrections decreasing their values by up to 4%. Additionally, @fig:data-p-p-3d indicates that all corrections amplify resonance effects.

#figure(
  pdf("../data/LHC22o_pass7_minBias_medium/p-p/data_correction.pdf"),
  caption: [
    Data in 1D and 2D for proton-proton.
  ],
) <fig:data-p-p>

#figure(
  pdf("../data/LHC22o_pass7_minBias_medium/p-p/corr_func_compare.pdf"),
  caption: [
    Correlation function for proton-proton from real data ($p p$ collisions).
  ],
) <fig:data-p-p-3d>

Proton anti-proton pair (@fig:data-p-ap) shows no significant differences between 1D and 2D correction effects. However, both ratios show a large increase in same jet peak area, reaching 20% in both dimensions (@fig:data-p-p-3d).

#figure(
  pdf("../data/LHC22o_pass7_minBias_medium/p-ap/data_correction.pdf"),
  caption: [
    Data in 1D and 2D for proton anti-proton.
  ],
) <fig:data-p-ap>

#figure(
  pdf("../data/LHC22o_pass7_minBias_medium/p-ap/corr_func_compare.pdf"),
  caption: [
    Correlation function for proton anti-proton from real data ($p p$ collisions).
  ],
) <fig:data-p-ap-3d>


= Conclusion

This thesis successfully developed and validated a new, semi-automated workflow for calculating reconstruction efficiency and applying efficiency corrections to angular correlation functions within the ALICE experiment's Run 3 O2Physics framework. The thesis has replaced the previous ad-hoc correction methods with a reusable, and more robust solution, improving the reliability of future analyses.

The implemented workflow starts with a ROOT macro that, based on MC simulation data, generates one-, two-, or three-dimensional correction weights which account for both reconstruction efficiency and contamination from secondary particles. The workflow then uploads these weights to the CCDB for later use by running a ready-to-use tool called `o2-ccdb-upload`. Finally, the `FemtoUniverseEfficiencyCorrection` class, a C++ abstraction integrated into the O2Physics/FemtoUniverse framework, lets analysis tasks retrieve and apply the corrections directly, based on a defined configuration.

A Monte Carlo closure test confirmed the validity of the new method. By comparing the corrected, reconstructed data with the MC truth for pion, kaon, and proton pairs, the test showed that the workflow effectively minimizes deviation from true values. A chi-squared analysis showed that two-dimensional corrections improve the agreement between the data and the MC truth more than uncorrected or 1D-corrected data.

Finally, applying the workflow to real collision data showed that the corrections produced promising results outside of the simulation environment. The analysis includes a comparison of different particle pairs with and without corrections. At the time of writing this thesis, a few group members have already used the workflow in their analysis tasks. This thesis tests it on specifically chosen particle pairs, however its design allows generalization to other particle combinations. The future plan involves integrating the workflow with most of the `FemtoUniverse`.

#clearpage()

#page-without-numbering(title: "Bibliography")[
  #bibliography("main.bib", title: none)
]

#clearpage()

#page-without-numbering(title: "List of Figures")[
  #outline(title: none, target: figure)
]
