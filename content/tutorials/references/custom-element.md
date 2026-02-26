+++
title = "Custom Elements"
weight = 2
date = "2025-02-25"
+++

This tutorial goes over all the information you need to create your own custom elements.

<!-- more -->

# Pinout

The Alchitry V2 boards have
three [DF40](https://www.hirose.com/en/product/document?clcode=&productname=&series=DF40&documenttype=Catalog&lang=en&documentid=en_DF40_CAT)
connectors on a side.

The 50-pin connector is the _Control_ header.
It has pins for power and miscellaneous control and status pins.

The two 80-pin connectors have up to 52 IO pins on each with the remaining pins being used as grounds.
The connector closest to the _Control_ header is _Bank A_ and the other is _Bank B_.

The 50-pin connector is `DF40HC(4.0)-50DS-0.4V(51)` when used on the top and the mating `DF40C-50DP-0.4V(51)` when on
the bottom.

The 80-pin connectors are `DF40HC(4.0)-80DS-0.4V(51)` when used on the top and the mating `DF40C-80DP-0.4V(51)` when on
the bottom.

<img src="https://cdn.alchitry.com/elements/AU_v2_Banks_Labeled.svg" alt="Alchitry V2 Banks" style="width: min(100%, 600px);" />

Pin 1 of each connector is at the bottom left for each in the image above.

The pinout of each board follows a general template, but they all vary a little from each other.
See below for the full pinouts.

## Cu

<details class="pinout-details">
<summary>Pinout Table</summary>
<div class="pinout-table-group">
<div class="pinout-table-container">
<h2>Bank A</h2>
<table class="pin-table" aria-label="Pin table">
  <colgroup>
    <col class="outer">
    <col class="num">
    <col class="num">
    <col class="outer">
  </colgroup>
  <tbody>
    <tr>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
      <td class="num">1</td>
      <td class="num">2</td>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-io">IO</span></td>
      <td class="num">3</td>
      <td class="num">4</td>
      <td class="outer"><span class="pill c-io">IO</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-io">IO</span></td>
      <td class="num">5</td>
      <td class="num">6</td>
      <td class="outer"><span class="pill c-io">IO</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
      <td class="num">7</td>
      <td class="num">8</td>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-io">IO</span></td>
      <td class="num">9</td>
      <td class="num">10</td>
      <td class="outer"><span class="pill c-io">IO</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-io">IO</span></td>
      <td class="num">11</td>
      <td class="num">12</td>
      <td class="outer"><span class="pill c-io">IO</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
      <td class="num">13</td>
      <td class="num">14</td>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-io">IO</span></td>
      <td class="num">15</td>
      <td class="num">16</td>
      <td class="outer"><span class="pill c-io">IO</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-io">IO</span></td>
      <td class="num">17</td>
      <td class="num">18</td>
      <td class="outer"><span class="pill c-io">IO</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
      <td class="num">19</td>
      <td class="num">20</td>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-io">IO</span></td>
      <td class="num">21</td>
      <td class="num">22</td>
      <td class="outer"><span class="pill c-io">IO</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-io">IO</span></td>
      <td class="num">23</td>
      <td class="num">24</td>
      <td class="outer"><span class="pill c-io">IO</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
      <td class="num">25</td>
      <td class="num">26</td>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-io">IO</span></td>
      <td class="num">27</td>
      <td class="num">28</td>
      <td class="outer"><span class="pill c-io">IO</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-io">IO</span></td>
      <td class="num">29</td>
      <td class="num">30</td>
      <td class="outer"><span class="pill c-io">IO</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
      <td class="num">31</td>
      <td class="num">32</td>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-io">IO</span></td>
      <td class="num">33</td>
      <td class="num">34</td>
      <td class="outer"><span class="pill c-io">IO</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-io">IO</span></td>
      <td class="num">35</td>
      <td class="num">36</td>
      <td class="outer"><span class="pill c-io">IO</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
      <td class="num">37</td>
      <td class="num">38</td>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
    </tr>
        <tr>
      <td class="outer"><span class="pill c-io">IO</span></td>
      <td class="num">39</td>
      <td class="num">40</td>
      <td class="outer"><span class="pill c-io">IO</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-clock">IO - GBIN</span></td>
      <td class="num">41</td>
      <td class="num">42</td>
      <td class="outer"><span class="pill c-clock">IO - GBIN</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
      <td class="num">43</td>
      <td class="num">44</td>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-io">IO</span></td>
      <td class="num">45</td>
      <td class="num">46</td>
      <td class="outer"><span class="pill c-io">IO</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-clock">IO - GBIN</span></td>
      <td class="num">47</td>
      <td class="num">48</td>
      <td class="outer"><span class="pill c-clock">IO - GBIN</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
      <td class="num">49</td>
      <td class="num">50</td>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-io">IO</span></td>
      <td class="num">51</td>
      <td class="num">52</td>
      <td class="outer"><span class="pill c-io">IO</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-io">IO</span></td>
      <td class="num">53</td>
      <td class="num">54</td>
      <td class="outer"><span class="pill c-io">IO</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
      <td class="num">55</td>
      <td class="num">56</td>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-io">IO</span></td>
      <td class="num">57</td>
      <td class="num">58</td>
      <td class="outer"><span class="pill c-io">IO</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-io">IO</span></td>
      <td class="num">59</td>
      <td class="num">60</td>
      <td class="outer"><span class="pill c-io">IO</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
      <td class="num">61</td>
      <td class="num">62</td>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-io">IO</span></td>
      <td class="num">63</td>
      <td class="num">64</td>
      <td class="outer"><span class="pill c-io">IO</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-io">IO</span></td>
      <td class="num">65</td>
      <td class="num">66</td>
      <td class="outer"><span class="pill c-io">IO</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
      <td class="num">67</td>
      <td class="num">68</td>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
    </tr>    <tr>
      <td class="outer"><span class="pill c-io">IO</span></td>
      <td class="num">69</td>
      <td class="num">70</td>
      <td class="outer"><span class="pill c-io">IO</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-io">IO</span></td>
      <td class="num">71</td>
      <td class="num">72</td>
      <td class="outer"><span class="pill c-io">IO</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
      <td class="num">73</td>
      <td class="num">74</td>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
    </tr>    <tr>
      <td class="outer"><span class="pill c-io">IO</span></td>
      <td class="num">75</td>
      <td class="num">76</td>
      <td class="outer"><span class="pill c-io">IO</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-io">IO</span></td>
      <td class="num">77</td>
      <td class="num">78</td>
      <td class="outer"><span class="pill c-io">IO</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
      <td class="num">79</td>
      <td class="num">80</td>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
    </tr>
  </tbody>
</table>
</div>
<div class="pinout-table-container">
<h2>Bank B</h2>
<table class="pin-table" aria-label="Pin table">
  <colgroup>
    <col class="outer">
    <col class="num">
    <col class="num">
    <col class="outer">
  </colgroup>
  <tbody>
    <tr>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
      <td class="num">1</td>
      <td class="num">2</td>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-io">IO</span></td>
      <td class="num">3</td>
      <td class="num">4</td>
      <td class="outer"><span class="pill c-io">IO</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-io">IO</span></td>
      <td class="num">5</td>
      <td class="num">6</td>
      <td class="outer"><span class="pill c-io">IO</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
      <td class="num">7</td>
      <td class="num">8</td>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-io">IO</span></td>
      <td class="num">9</td>
      <td class="num">10</td>
      <td class="outer"><span class="pill c-io">IO</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-io">IO</span></td>
      <td class="num">11</td>
      <td class="num">12</td>
      <td class="outer"><span class="pill c-io">IO</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
      <td class="num">13</td>
      <td class="num">14</td>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-io">IO</span></td>
      <td class="num">15</td>
      <td class="num">16</td>
      <td class="outer"><span class="pill c-io">IO</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-io">IO</span></td>
      <td class="num">17</td>
      <td class="num">18</td>
      <td class="outer"><span class="pill c-io">IO</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
      <td class="num">19</td>
      <td class="num">20</td>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-io">IO</span></td>
      <td class="num">21</td>
      <td class="num">22</td>
      <td class="outer"><span class="pill c-io">IO</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-io">IO</span></td>
      <td class="num">23</td>
      <td class="num">24</td>
      <td class="outer"><span class="pill c-io">IO</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
      <td class="num">25</td>
      <td class="num">26</td>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-io">IO</span></td>
      <td class="num">27</td>
      <td class="num">28</td>
      <td class="outer"><span class="pill c-io">IO</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-io">IO</span></td>
      <td class="num">29</td>
      <td class="num">30</td>
      <td class="outer"><span class="pill c-io">IO</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
      <td class="num">31</td>
      <td class="num">32</td>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-io">IO - SDA</span></td>
      <td class="num">33</td>
      <td class="num">34</td>
      <td class="outer"><span class="pill c-split-io-config">IO - CBSEL0</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-io">IO - SCL</span></td>
      <td class="num">35</td>
      <td class="num">36</td>
      <td class="outer"><span class="pill c-split-io-config">IO - CBSEL1</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
      <td class="num">37</td>
      <td class="num">38</td>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
    </tr>
        <tr>
      <td class="outer"><span class="pill c-io">IO</span></td>
      <td class="num">39</td>
      <td class="num">40</td>
      <td class="outer"><span class="pill c-nc">-</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-clock">IO - GBIN</span></td>
      <td class="num">41</td>
      <td class="num">42</td>
      <td class="outer"><span class="pill c-clock">IO - GBIN</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
      <td class="num">43</td>
      <td class="num">44</td>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-nc">-</span></td>
      <td class="num">45</td>
      <td class="num">46</td>
      <td class="outer"><span class="pill c-nc">-</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-nc">-</span></td>
      <td class="num">47</td>
      <td class="num">48</td>
      <td class="outer"><span class="pill c-nc">-</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
      <td class="num">49</td>
      <td class="num">50</td>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-nc">-</span></td>
      <td class="num">51</td>
      <td class="num">52</td>
      <td class="outer"><span class="pill c-nc">-</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-nc">-</span></td>
      <td class="num">53</td>
      <td class="num">54</td>
      <td class="outer"><span class="pill c-nc">-</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
      <td class="num">55</td>
      <td class="num">56</td>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-nc">-</span></td>
      <td class="num">57</td>
      <td class="num">58</td>
      <td class="outer"><span class="pill c-nc">-</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-nc">-</span></td>
      <td class="num">59</td>
      <td class="num">60</td>
      <td class="outer"><span class="pill c-nc">-</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
      <td class="num">61</td>
      <td class="num">62</td>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-nc">-</span></td>
      <td class="num">63</td>
      <td class="num">64</td>
      <td class="outer"><span class="pill c-nc">-</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-nc">-</span></td>
      <td class="num">65</td>
      <td class="num">66</td>
      <td class="outer"><span class="pill c-nc">-</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
      <td class="num">67</td>
      <td class="num">68</td>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
    </tr>    
    <tr>
      <td class="outer"><span class="pill c-nc">-</span></td>
      <td class="num">69</td>
      <td class="num">70</td>
      <td class="outer"><span class="pill c-nc">-</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-nc">-</span></td>
      <td class="num">71</td>
      <td class="num">72</td>
      <td class="outer"><span class="pill c-nc">-</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
      <td class="num">73</td>
      <td class="num">74</td>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
    </tr>    
    <tr>
      <td class="outer"><span class="pill c-nc">-</span></td>
      <td class="num">75</td>
      <td class="num">76</td>
      <td class="outer"><span class="pill c-nc">-</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-nc">-</span></td>
      <td class="num">77</td>
      <td class="num">78</td>
      <td class="outer"><span class="pill c-nc">-</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
      <td class="num">79</td>
      <td class="num">80</td>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
    </tr>
  </tbody>
</table>
</div>
<div class="pinout-table-container">
<h2>Control</h2>
<table class="pin-table" aria-label="Pin table">
  <colgroup>
    <col class="outer">
    <col class="num">
    <col class="num">
    <col class="outer">
  </colgroup>
  <tbody>
    <tr>
      <td class="outer"><span class="pill c-3v3">+3.3V</span></td>
      <td class="num">1</td>
      <td class="num">2</td>
      <td class="outer"><span class="pill c-vdd">VDD</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-3v3">+3.3V</span></td>
      <td class="num">3</td>
      <td class="num">4</td>
      <td class="outer"><span class="pill c-vdd">VDD</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-3v3">+3.3V</span></td>
      <td class="num">5</td>
      <td class="num">6</td>
      <td class="outer"><span class="pill c-vdd">VDD</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-3v3">+3.3V</span></td>
      <td class="num">7</td>
      <td class="num">8</td>
      <td class="outer"><span class="pill c-vdd">VDD</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-3v3">+3.3V</span></td>
      <td class="num">9</td>
      <td class="num">10</td>
      <td class="outer"><span class="pill c-vdd">VDD</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-3v3">+3.3V</span></td>
      <td class="num">11</td>
      <td class="num">12</td>
      <td class="outer"><span class="pill c-vdd">VDD</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-3v3">+3.3V</span></td>
      <td class="num">13</td>
      <td class="num">14</td>
      <td class="outer"><span class="pill c-vdd">VDD</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-3v3">+3.3V</span></td>
      <td class="num">15</td>
      <td class="num">16</td>
      <td class="outer"><span class="pill c-vdd">VDD</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
      <td class="num">17</td>
      <td class="num">18</td>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
      <td class="num">19</td>
      <td class="num">20</td>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
      <td class="num">21</td>
      <td class="num">22</td>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
      <td class="num">23</td>
      <td class="num">24</td>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
      <td class="num">25</td>
      <td class="num">26</td>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
      <td class="num">27</td>
      <td class="num">28</td>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-io">LED 0</span></td>
      <td class="num">29</td>
      <td class="num">30</td>
      <td class="outer"><span class="pill c-io">LED 4</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-io">LED 1</span></td>
      <td class="num">31</td>
      <td class="num">32</td>
      <td class="outer"><span class="pill c-io">LED 5</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-io">LED 2</span></td>
      <td class="num">33</td>
      <td class="num">34</td>
      <td class="outer"><span class="pill c-io">LED 6</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-io">LED 3</span></td>
      <td class="num">35</td>
      <td class="num">36</td>
      <td class="outer"><span class="pill c-io">LED 7</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-io">RESET</span></td>
      <td class="num">37</td>
      <td class="num">38</td>
      <td class="outer"><span class="pill c-nc">-</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-config">DONE</span></td>
      <td class="num">39</td>
      <td class="num">40</td>
      <td class="outer"><span class="pill c-nc">-</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-config">C_RESET</span></td>
      <td class="num">41</td>
      <td class="num">42</td>
      <td class="outer"><span class="pill c-nc">-</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-config">ICE SS</span></td>
      <td class="num">43</td>
      <td class="num">44</td>
      <td class="outer"><span class="pill c-nc">-</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-config">ICE SCK</span></td>
      <td class="num">45</td>
      <td class="num">46</td>
      <td class="outer"><span class="pill c-nc">-</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-config">ICE MISO</span></td>
      <td class="num">47</td>
      <td class="num">48</td>
      <td class="outer"><span class="pill c-nc">-</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-config">ICE MOSI</span></td>
      <td class="num">49</td>
      <td class="num">50</td>
      <td class="outer"><span class="pill c-nc">-</span></td>
    </tr>
  </tbody>
</table>
</div>
</div>
<div class="pinout-legend">
<h2>Legend</h2>
<table class="pin-table" aria-label="Pin table">
  <colgroup>
    <col class="outer">
    <col class="num">
  </colgroup>
<tbody>
<tr>
  <td class="outer"><span class="pill c-io">IO</span></td>
  <td>Standard IO. <code>SDA</code> and <code>SCL</code> also connect to the QWIIC connector. <code>CBSELn</code> can be used to select one of multiple boot images</td>
</tr>
<tr>
  <td class="outer"><span class="pill c-clock">GBIN</span></td>
  <td>Clock capable input</td>
</tr>
<tr>
  <td class="outer"><span class="pill c-config">CONFIG</span></td>
  <td>Configuration signal</td>
</tr>
<tr>
  <td class="outer"><span class="pill c-3v3">+3.3V</span></td>
  <td>3.3V output</td>
</tr>
<tr>
  <td class="outer"><span class="pill c-vdd">VDD</span></td>
  <td>5V-12V board power. When plugged into USB, this can supply 5V. The USB port is protected against higher voltages</td>
</tr>
<tr>
  <td class="outer"><span class="pill c-gnd">GND</span></td>
  <td>Ground</td>
</tr>
<tr>
  <td class="outer"><span class="pill c-nc">-</span></td>
  <td>No connection</td>
</tr>
</tbody>
</table>
</div>
</details>

## Au

<details class="pinout-details">
<summary>Pinout Table</summary>
<div class="pinout-table-group">
<div class="pinout-table-container">
<h2>Bank A</h2>
<table class="pin-table" aria-label="Pin table">
  <colgroup>
    <col class="outer">
    <col class="num">
    <col class="num">
    <col class="outer">
  </colgroup>
  <tbody>
    <tr>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
      <td class="num">1</td>
      <td class="num">2</td>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-io-diff">IO N</span></td>
      <td class="num">3</td>
      <td class="num">4</td>
      <td class="outer"><span class="pill c-io-diff">IO N</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-io-diff">IO P</span></td>
      <td class="num">5</td>
      <td class="num">6</td>
      <td class="outer"><span class="pill c-io-diff">IO P</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
      <td class="num">7</td>
      <td class="num">8</td>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-io-diff">IO N</span></td>
      <td class="num">9</td>
      <td class="num">10</td>
      <td class="outer"><span class="pill c-io-diff">IO N</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-io-diff">IO P</span></td>
      <td class="num">11</td>
      <td class="num">12</td>
      <td class="outer"><span class="pill c-io-diff">IO P</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
      <td class="num">13</td>
      <td class="num">14</td>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-io-diff">IO N</span></td>
      <td class="num">15</td>
      <td class="num">16</td>
      <td class="outer"><span class="pill c-io-diff">IO N</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-io-diff">IO P</span></td>
      <td class="num">17</td>
      <td class="num">18</td>
      <td class="outer"><span class="pill c-io-diff">IO P</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
      <td class="num">19</td>
      <td class="num">20</td>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-io-diff">IO N</span></td>
      <td class="num">21</td>
      <td class="num">22</td>
      <td class="outer"><span class="pill c-io-diff">IO N</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-io-diff">IO P</span></td>
      <td class="num">23</td>
      <td class="num">24</td>
      <td class="outer"><span class="pill c-io-diff">IO P</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
      <td class="num">25</td>
      <td class="num">26</td>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-io-diff">IO N</span></td>
      <td class="num">27</td>
      <td class="num">28</td>
      <td class="outer"><span class="pill c-io-diff">IO N</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-io-diff">IO P</span></td>
      <td class="num">29</td>
      <td class="num">30</td>
      <td class="outer"><span class="pill c-io-diff">IO P</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
      <td class="num">31</td>
      <td class="num">32</td>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-io-diff">IO N</span></td>
      <td class="num">33</td>
      <td class="num">34</td>
      <td class="outer"><span class="pill c-io-diff">IO N</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-io-diff">IO P</span></td>
      <td class="num">35</td>
      <td class="num">36</td>
      <td class="outer"><span class="pill c-io-diff">IO P</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
      <td class="num">37</td>
      <td class="num">38</td>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
    </tr>
        <tr>
      <td class="outer"><span class="pill c-clock">IO N - MRCC</span></td>
      <td class="num">39</td>
      <td class="num">40</td>
      <td class="outer"><span class="pill c-clock">IO N - SRCC</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-clock">IO P - MRCC</span></td>
      <td class="num">41</td>
      <td class="num">42</td>
      <td class="outer"><span class="pill c-clock">IO P - SRCC</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
      <td class="num">43</td>
      <td class="num">44</td>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-clock">IO N - MRCC</span></td>
      <td class="num">45</td>
      <td class="num">46</td>
      <td class="outer"><span class="pill c-clock">IO N - SRCC</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-clock">IO P - MRCC</span></td>
      <td class="num">47</td>
      <td class="num">48</td>
      <td class="outer"><span class="pill c-clock">IO P - SRCC</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
      <td class="num">49</td>
      <td class="num">50</td>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-io-diff">IO N</span></td>
      <td class="num">51</td>
      <td class="num">52</td>
      <td class="outer"><span class="pill c-io-diff">IO N</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-io-diff">IO P</span></td>
      <td class="num">53</td>
      <td class="num">54</td>
      <td class="outer"><span class="pill c-io-diff">IO P</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
      <td class="num">55</td>
      <td class="num">56</td>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-split-diff-analog">IO N A</span></td>
      <td class="num">57</td>
      <td class="num">58</td>
      <td class="outer"><span class="pill c-split-diff-analog">IO N A</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-split-diff-analog">IO P A</span></td>
      <td class="num">59</td>
      <td class="num">60</td>
      <td class="outer"><span class="pill c-split-diff-analog">IO P A</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
      <td class="num">61</td>
      <td class="num">62</td>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-split-diff-analog">IO N A</span></td>
      <td class="num">63</td>
      <td class="num">64</td>
      <td class="outer"><span class="pill c-split-diff-analog">IO N A</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-split-diff-analog">IO P A</span></td>
      <td class="num">65</td>
      <td class="num">66</td>
      <td class="outer"><span class="pill c-split-diff-analog">IO P A</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
      <td class="num">67</td>
      <td class="num">68</td>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
    </tr>    <tr>
      <td class="outer"><span class="pill c-split-diff-analog">IO N A</span></td>
      <td class="num">69</td>
      <td class="num">70</td>
      <td class="outer"><span class="pill c-split-diff-analog">IO N A</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-split-diff-analog">IO P A</span></td>
      <td class="num">71</td>
      <td class="num">72</td>
      <td class="outer"><span class="pill c-split-diff-analog">IO P A</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
      <td class="num">73</td>
      <td class="num">74</td>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
    </tr>    <tr>
      <td class="outer"><span class="pill c-split-diff-analog">IO N A</span></td>
      <td class="num">75</td>
      <td class="num">76</td>
      <td class="outer"><span class="pill c-split-diff-analog">IO N A</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-split-diff-analog">IO P A</span></td>
      <td class="num">77</td>
      <td class="num">78</td>
      <td class="outer"><span class="pill c-split-diff-analog">IO P A</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
      <td class="num">79</td>
      <td class="num">80</td>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
    </tr>
  </tbody>
</table>
</div>
<div class="pinout-table-container">
<h2>Bank B</h2>
<table class="pin-table" aria-label="Pin table">
  <colgroup>
    <col class="outer">
    <col class="num">
    <col class="num">
    <col class="outer">
  </colgroup>
  <tbody>
    <tr>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
      <td class="num">1</td>
      <td class="num">2</td>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-io-diff">IO N</span></td>
      <td class="num">3</td>
      <td class="num">4</td>
      <td class="outer"><span class="pill c-io-diff">IO N</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-io-diff">IO P</span></td>
      <td class="num">5</td>
      <td class="num">6</td>
      <td class="outer"><span class="pill c-io-diff">IO P</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
      <td class="num">7</td>
      <td class="num">8</td>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-io-diff">IO N</span></td>
      <td class="num">9</td>
      <td class="num">10</td>
      <td class="outer"><span class="pill c-io-diff">IO N</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-io-diff">IO P</span></td>
      <td class="num">11</td>
      <td class="num">12</td>
      <td class="outer"><span class="pill c-io-diff">IO P</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
      <td class="num">13</td>
      <td class="num">14</td>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-io-diff">IO N</span></td>
      <td class="num">15</td>
      <td class="num">16</td>
      <td class="outer"><span class="pill c-io-diff">IO N</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-io-diff">IO P</span></td>
      <td class="num">17</td>
      <td class="num">18</td>
      <td class="outer"><span class="pill c-io-diff">IO P</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
      <td class="num">19</td>
      <td class="num">20</td>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-io-diff">IO N</span></td>
      <td class="num">21</td>
      <td class="num">22</td>
      <td class="outer"><span class="pill c-io-diff">IO N</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-io-diff">IO P</span></td>
      <td class="num">23</td>
      <td class="num">24</td>
      <td class="outer"><span class="pill c-io-diff">IO P</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
      <td class="num">25</td>
      <td class="num">26</td>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-io-diff">IO N</span></td>
      <td class="num">27</td>
      <td class="num">28</td>
      <td class="outer"><span class="pill c-io-diff">IO N</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-io-diff">IO P</span></td>
      <td class="num">29</td>
      <td class="num">30</td>
      <td class="outer"><span class="pill c-io-diff">IO P</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
      <td class="num">31</td>
      <td class="num">32</td>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-io">IO - SDA</span></td>
      <td class="num">33</td>
      <td class="num">34</td>
      <td class="outer"><span class="pill c-io-diff">IO N</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-io">IO - SCL</span></td>
      <td class="num">35</td>
      <td class="num">36</td>
      <td class="outer"><span class="pill c-io-diff">IO P</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
      <td class="num">37</td>
      <td class="num">38</td>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
    </tr>
        <tr>
      <td class="outer"><span class="pill c-clock">IO N - SRCC</span></td>
      <td class="num">39</td>
      <td class="num">40</td>
      <td class="outer"><span class="pill c-clock">IO N - SRCC</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-clock">IO P - SRCC</span></td>
      <td class="num">41</td>
      <td class="num">42</td>
      <td class="outer"><span class="pill c-clock">IO P - SRCC</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
      <td class="num">43</td>
      <td class="num">44</td>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-clock">IO N - MRCC</span></td>
      <td class="num">45</td>
      <td class="num">46</td>
      <td class="outer"><span class="pill c-io">IO - 1.35V</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-clock">IO P - MRCC</span></td>
      <td class="num">47</td>
      <td class="num">48</td>
      <td class="outer"><span class="pill c-io">IO - 1.35V</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
      <td class="num">49</td>
      <td class="num">50</td>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-multi">IO N MV</span></td>
      <td class="num">51</td>
      <td class="num">52</td>
      <td class="outer"><span class="pill c-multi">IO N MV</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-multi">IO P MV</span></td>
      <td class="num">53</td>
      <td class="num">54</td>
      <td class="outer"><span class="pill c-multi">IO P MV</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
      <td class="num">55</td>
      <td class="num">56</td>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-multi">IO N MV</span></td>
      <td class="num">57</td>
      <td class="num">58</td>
      <td class="outer"><span class="pill c-multi">IO N MV</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-multi">IO P MV</span></td>
      <td class="num">59</td>
      <td class="num">60</td>
      <td class="outer"><span class="pill c-multi">IO P MV</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
      <td class="num">61</td>
      <td class="num">62</td>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-multi">IO N MV</span></td>
      <td class="num">63</td>
      <td class="num">64</td>
      <td class="outer"><span class="pill c-multi">IO N MV</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-multi">IO P MV</span></td>
      <td class="num">65</td>
      <td class="num">66</td>
      <td class="outer"><span class="pill c-multi">IO P MV</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
      <td class="num">67</td>
      <td class="num">68</td>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
    </tr>    <tr>
      <td class="outer"><span class="pill c-multi">IO N MV</span></td>
      <td class="num">69</td>
      <td class="num">70</td>
      <td class="outer"><span class="pill c-multi">IO N MV</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-multi">IO P MV</span></td>
      <td class="num">71</td>
      <td class="num">72</td>
      <td class="outer"><span class="pill c-multi">IO P MV</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
      <td class="num">73</td>
      <td class="num">74</td>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
    </tr>    <tr>
      <td class="outer"><span class="pill c-multi">IO N MV</span></td>
      <td class="num">75</td>
      <td class="num">76</td>
      <td class="outer"><span class="pill c-multi">IO N MV</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-multi">IO P MV</span></td>
      <td class="num">77</td>
      <td class="num">78</td>
      <td class="outer"><span class="pill c-multi">IO P MV</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
      <td class="num">79</td>
      <td class="num">80</td>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
    </tr>
  </tbody>
</table>
</div>
<div class="pinout-table-container">
<h2>Control</h2>
<table class="pin-table" aria-label="Pin table">
  <colgroup>
    <col class="outer">
    <col class="num">
    <col class="num">
    <col class="outer">
  </colgroup>
  <tbody>
    <tr>
      <td class="outer"><span class="pill c-3v3">+3.3V</span></td>
      <td class="num">1</td>
      <td class="num">2</td>
      <td class="outer"><span class="pill c-vdd">VDD</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-3v3">+3.3V</span></td>
      <td class="num">3</td>
      <td class="num">4</td>
      <td class="outer"><span class="pill c-vdd">VDD</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-3v3">+3.3V</span></td>
      <td class="num">5</td>
      <td class="num">6</td>
      <td class="outer"><span class="pill c-vdd">VDD</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-3v3">+3.3V</span></td>
      <td class="num">7</td>
      <td class="num">8</td>
      <td class="outer"><span class="pill c-vdd">VDD</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-3v3">+3.3V</span></td>
      <td class="num">9</td>
      <td class="num">10</td>
      <td class="outer"><span class="pill c-vdd">VDD</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-3v3">+3.3V</span></td>
      <td class="num">11</td>
      <td class="num">12</td>
      <td class="outer"><span class="pill c-vdd">VDD</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-3v3">+3.3V</span></td>
      <td class="num">13</td>
      <td class="num">14</td>
      <td class="outer"><span class="pill c-vdd">VDD</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-3v3">+3.3V</span></td>
      <td class="num">15</td>
      <td class="num">16</td>
      <td class="outer"><span class="pill c-vdd">VDD</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
      <td class="num">17</td>
      <td class="num">18</td>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
      <td class="num">19</td>
      <td class="num">20</td>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
      <td class="num">21</td>
      <td class="num">22</td>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
      <td class="num">23</td>
      <td class="num">24</td>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
      <td class="num">25</td>
      <td class="num">26</td>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
      <td class="num">27</td>
      <td class="num">28</td>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-io">LED 0</span></td>
      <td class="num">29</td>
      <td class="num">30</td>
      <td class="outer"><span class="pill c-io">LED 4</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-io">LED 1</span></td>
      <td class="num">31</td>
      <td class="num">32</td>
      <td class="outer"><span class="pill c-io">LED 5</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-io">LED 2</span></td>
      <td class="num">33</td>
      <td class="num">34</td>
      <td class="outer"><span class="pill c-io">LED 6</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-io">LED 3</span></td>
      <td class="num">35</td>
      <td class="num">36</td>
      <td class="outer"><span class="pill c-io">LED 7</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-io">RESET</span></td>
      <td class="num">37</td>
      <td class="num">38</td>
      <td class="outer"><span class="pill c-multi">VBSEL A</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-config">DONE</span></td>
      <td class="num">39</td>
      <td class="num">40</td>
      <td class="outer"><span class="pill c-multi">VBSEL B</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-config">PROGRAM</span></td>
      <td class="num">41</td>
      <td class="num">42</td>
      <td class="outer"><span class="pill c-analog">A1.8V</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-config">TMS</span></td>
      <td class="num">43</td>
      <td class="num">44</td>
      <td class="outer"><span class="pill c-analog">AV P</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-config">TCK</span></td>
      <td class="num">45</td>
      <td class="num">46</td>
      <td class="outer"><span class="pill c-analog">AV N</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-config">TDI</span></td>
      <td class="num">47</td>
      <td class="num">48</td>
      <td class="outer"><span class="pill c-analog">AREF</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-config">TDO</span></td>
      <td class="num">49</td>
      <td class="num">50</td>
      <td class="outer"><span class="pill c-analog">AGND</span></td>
    </tr>
  </tbody>
</table>
<h2>VBSEL Values</h2>
<table class="mv-table">
  <thead>
    <tr>
      <th>VBSEL A</th>
      <th>VBSEL B</th>
      <th>MV VCCO</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>floating</td>
      <td>floating</td>
      <td>3.3</td>
    </tr>
    <tr>
      <td>low</td>
      <td>low</td>
      <td>3.3</td>
    </tr>
    <tr>
      <td>low</td>
      <td>high</td>
      <td>3.3</td>
    </tr>
    <tr>
      <td>high</td>
      <td>low</td>
      <td>1.8</td>
    </tr>
    <tr>
      <td>high</td>
      <td>high</td>
      <td>2.5</td>
    </tr>
    <tr>
      <td>VBSEL B</td>
      <td>VBSEL A</td>
      <td>2.5</td>
    </tr>
  </tbody>
</table>
<p>low = 0-0.9 volts<br/>
high = 1.1-3.3 volts</p>
</div>
</div>
<div class="pinout-legend">
<h2>Legend</h2>
<table class="pin-table" aria-label="Pin table">
  <colgroup>
    <col class="outer">
    <col class="num">
  </colgroup>
<tbody>
<tr>
  <td class="outer"><span class="pill c-io">IO</span></td>
  <td>Standard IO. <code>SDA</code> and <code>SCL</code> also connect to the QWIIC connector. The 1.35V pins are not 3.3V tolerant</td>
</tr>
<tr>
  <td class="outer"><span class="pill c-io-diff">IO N/P</span></td>
  <td>Differential capable IO</td>
</tr>
<tr>
  <td class="outer"><span class="pill c-clock">MRCC/SRCC</span></td>
  <td>Clock capable input. Single ended clocks must go to the <code>P</code> pin of the pair</td>
</tr>
<tr>
  <td class="outer"><span class="pill c-multi">Multi-voltage</span></td>
  <td>Multi-voltage pin. The VCCO for these pins is controllable via <code>VBSEL A</code> and <code>VBSEL B</code></td>
</tr>
<tr>
  <td class="outer"><span class="pill c-analog">Analog</span></td>
  <td>Analog signal. <code>IO N/P A</code> and <code>AV P/N</code> are 1V inputs</td>
</tr>
<tr>
  <td class="outer"><span class="pill c-config">CONFIG</span></td>
  <td>Configuration signal</td>
</tr>
<tr>
  <td class="outer"><span class="pill c-3v3">+3.3V</span></td>
  <td>3.3V output</td>
</tr>
<tr>
  <td class="outer"><span class="pill c-vdd">VDD</span></td>
  <td>5V-12V board power. When plugged into USB, this can supply 5V. The USB port is protected against higher voltages</td>
</tr>
<tr>
  <td class="outer"><span class="pill c-gnd">GND</span></td>
  <td>Ground</td>
</tr>
</tbody>
</table>
</div>
</details>

## Pt


<details class="pinout-details">
<summary>Top Pinout Table</summary>
<div class="pinout-table-group">
<div class="pinout-table-container">
<h2>Bank A</h2>
<table class="pin-table" aria-label="Pin table">
  <colgroup>
    <col class="outer">
    <col class="num">
    <col class="num">
    <col class="outer">
  </colgroup>
  <tbody>
    <tr>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
      <td class="num">1</td>
      <td class="num">2</td>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-io-diff">IO N</span></td>
      <td class="num">3</td>
      <td class="num">4</td>
      <td class="outer"><span class="pill c-io-diff">IO N</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-io-diff">IO P</span></td>
      <td class="num">5</td>
      <td class="num">6</td>
      <td class="outer"><span class="pill c-io-diff">IO P</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
      <td class="num">7</td>
      <td class="num">8</td>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-io-diff">IO N</span></td>
      <td class="num">9</td>
      <td class="num">10</td>
      <td class="outer"><span class="pill c-io-diff">IO N</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-io-diff">IO P</span></td>
      <td class="num">11</td>
      <td class="num">12</td>
      <td class="outer"><span class="pill c-io-diff">IO P</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
      <td class="num">13</td>
      <td class="num">14</td>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-io-diff">IO N</span></td>
      <td class="num">15</td>
      <td class="num">16</td>
      <td class="outer"><span class="pill c-io-diff">IO N</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-io-diff">IO P</span></td>
      <td class="num">17</td>
      <td class="num">18</td>
      <td class="outer"><span class="pill c-io-diff">IO P</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
      <td class="num">19</td>
      <td class="num">20</td>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-io-diff">IO N</span></td>
      <td class="num">21</td>
      <td class="num">22</td>
      <td class="outer"><span class="pill c-io-diff">IO N</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-io-diff">IO P</span></td>
      <td class="num">23</td>
      <td class="num">24</td>
      <td class="outer"><span class="pill c-io-diff">IO P</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
      <td class="num">25</td>
      <td class="num">26</td>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-io-diff">IO N</span></td>
      <td class="num">27</td>
      <td class="num">28</td>
      <td class="outer"><span class="pill c-io-diff">IO N</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-io-diff">IO P</span></td>
      <td class="num">29</td>
      <td class="num">30</td>
      <td class="outer"><span class="pill c-io-diff">IO P</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
      <td class="num">31</td>
      <td class="num">32</td>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-io-diff">IO N</span></td>
      <td class="num">33</td>
      <td class="num">34</td>
      <td class="outer"><span class="pill c-io-diff">IO N</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-io-diff">IO P</span></td>
      <td class="num">35</td>
      <td class="num">36</td>
      <td class="outer"><span class="pill c-io-diff">IO P</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
      <td class="num">37</td>
      <td class="num">38</td>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
    </tr>
        <tr>
      <td class="outer"><span class="pill c-clock">IO N - MRCC</span></td>
      <td class="num">39</td>
      <td class="num">40</td>
      <td class="outer"><span class="pill c-clock">IO N - SRCC</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-clock">IO P - MRCC</span></td>
      <td class="num">41</td>
      <td class="num">42</td>
      <td class="outer"><span class="pill c-clock">IO P - SRCC</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
      <td class="num">43</td>
      <td class="num">44</td>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-clock">IO N - MRCC</span></td>
      <td class="num">45</td>
      <td class="num">46</td>
      <td class="outer"><span class="pill c-clock">IO N - SRCC</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-clock">IO P - MRCC</span></td>
      <td class="num">47</td>
      <td class="num">48</td>
      <td class="outer"><span class="pill c-clock">IO P - SRCC</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
      <td class="num">49</td>
      <td class="num">50</td>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-io-diff">IO N</span></td>
      <td class="num">51</td>
      <td class="num">52</td>
      <td class="outer"><span class="pill c-io-diff">IO N</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-io-diff">IO P</span></td>
      <td class="num">53</td>
      <td class="num">54</td>
      <td class="outer"><span class="pill c-io-diff">IO P</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
      <td class="num">55</td>
      <td class="num">56</td>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-split-diff-analog">IO N A</span></td>
      <td class="num">57</td>
      <td class="num">58</td>
      <td class="outer"><span class="pill c-split-diff-analog">IO N A</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-split-diff-analog">IO P A</span></td>
      <td class="num">59</td>
      <td class="num">60</td>
      <td class="outer"><span class="pill c-split-diff-analog">IO P A</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
      <td class="num">61</td>
      <td class="num">62</td>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-split-diff-analog">IO N A</span></td>
      <td class="num">63</td>
      <td class="num">64</td>
      <td class="outer"><span class="pill c-split-diff-analog">IO N A</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-split-diff-analog">IO P A</span></td>
      <td class="num">65</td>
      <td class="num">66</td>
      <td class="outer"><span class="pill c-split-diff-analog">IO P A</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
      <td class="num">67</td>
      <td class="num">68</td>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
    </tr>    <tr>
      <td class="outer"><span class="pill c-split-diff-analog">IO N A</span></td>
      <td class="num">69</td>
      <td class="num">70</td>
      <td class="outer"><span class="pill c-split-diff-analog">IO N A</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-split-diff-analog">IO P A</span></td>
      <td class="num">71</td>
      <td class="num">72</td>
      <td class="outer"><span class="pill c-split-diff-analog">IO P A</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
      <td class="num">73</td>
      <td class="num">74</td>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
    </tr>    <tr>
      <td class="outer"><span class="pill c-split-diff-analog">IO N A</span></td>
      <td class="num">75</td>
      <td class="num">76</td>
      <td class="outer"><span class="pill c-split-diff-analog">IO N A</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-split-diff-analog">IO P A</span></td>
      <td class="num">77</td>
      <td class="num">78</td>
      <td class="outer"><span class="pill c-split-diff-analog">IO P A</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
      <td class="num">79</td>
      <td class="num">80</td>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
    </tr>
  </tbody>
</table>
</div>
<div class="pinout-table-container">
<h2>Bank B</h2>
<table class="pin-table" aria-label="Pin table">
  <colgroup>
    <col class="outer">
    <col class="num">
    <col class="num">
    <col class="outer">
  </colgroup>
  <tbody>
    <tr>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
      <td class="num">1</td>
      <td class="num">2</td>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-io-diff">IO N</span></td>
      <td class="num">3</td>
      <td class="num">4</td>
      <td class="outer"><span class="pill c-io-diff">IO N</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-io-diff">IO P</span></td>
      <td class="num">5</td>
      <td class="num">6</td>
      <td class="outer"><span class="pill c-io-diff">IO P</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
      <td class="num">7</td>
      <td class="num">8</td>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-io-diff">IO N</span></td>
      <td class="num">9</td>
      <td class="num">10</td>
      <td class="outer"><span class="pill c-io-diff">IO N</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-io-diff">IO P</span></td>
      <td class="num">11</td>
      <td class="num">12</td>
      <td class="outer"><span class="pill c-io-diff">IO P</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
      <td class="num">13</td>
      <td class="num">14</td>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-io-diff">IO N</span></td>
      <td class="num">15</td>
      <td class="num">16</td>
      <td class="outer"><span class="pill c-io-diff">IO N</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-io-diff">IO P</span></td>
      <td class="num">17</td>
      <td class="num">18</td>
      <td class="outer"><span class="pill c-io-diff">IO P</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
      <td class="num">19</td>
      <td class="num">20</td>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-io-diff">IO N</span></td>
      <td class="num">21</td>
      <td class="num">22</td>
      <td class="outer"><span class="pill c-clock">IO N - SRCC</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-io-diff">IO P</span></td>
      <td class="num">23</td>
      <td class="num">24</td>
      <td class="outer"><span class="pill c-clock">IO P - SRCC</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
      <td class="num">25</td>
      <td class="num">26</td>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-clock">IO N - MRCC</span></td>
      <td class="num">27</td>
      <td class="num">28</td>
      <td class="outer"><span class="pill c-clock">IO N - SRCC</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-clock">IO P - MRCC</span></td>
      <td class="num">29</td>
      <td class="num">30</td>
      <td class="outer"><span class="pill c-clock">IO P - SRCC</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
      <td class="num">31</td>
      <td class="num">32</td>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-multi">IO N MV</span></td>
      <td class="num">33</td>
      <td class="num">34</td>
      <td class="outer"><span class="pill c-multi">IO N MV</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-multi">IO P MV</span></td>
      <td class="num">35</td>
      <td class="num">36</td>
      <td class="outer"><span class="pill c-multi">IO P MV</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
      <td class="num">37</td>
      <td class="num">38</td>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
    </tr>
        <tr>
      <td class="outer"><span class="pill c-split-multi-clock">IO N MV - MRCC</span></td>
      <td class="num">39</td>
      <td class="num">40</td>
      <td class="outer"><span class="pill c-split-multi-clock">IO N MV - SRCC</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-split-multi-clock">IO P MV - MRCC</span></td>
      <td class="num">41</td>
      <td class="num">42</td>
      <td class="outer"><span class="pill c-split-multi-clock">IO P MV - SRCC</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
      <td class="num">43</td>
      <td class="num">44</td>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-split-multi-clock">IO N MV - MRCC</span></td>
      <td class="num">45</td>
      <td class="num">46</td>
      <td class="outer"><span class="pill c-split-multi-clock">IO N MV - SRCC</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-split-multi-clock">IO P MV - MRCC</span></td>
      <td class="num">47</td>
      <td class="num">48</td>
      <td class="outer"><span class="pill c-split-multi-clock">IO P MV - SRCC</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
      <td class="num">49</td>
      <td class="num">50</td>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-multi">IO N MV</span></td>
      <td class="num">51</td>
      <td class="num">52</td>
      <td class="outer"><span class="pill c-multi">IO N MV</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-multi">IO P MV</span></td>
      <td class="num">53</td>
      <td class="num">54</td>
      <td class="outer"><span class="pill c-multi">IO P MV</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
      <td class="num">55</td>
      <td class="num">56</td>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-multi">IO N MV</span></td>
      <td class="num">57</td>
      <td class="num">58</td>
      <td class="outer"><span class="pill c-multi">IO N MV</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-multi">IO P MV</span></td>
      <td class="num">59</td>
      <td class="num">60</td>
      <td class="outer"><span class="pill c-multi">IO P MV</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
      <td class="num">61</td>
      <td class="num">62</td>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-multi">IO N MV</span></td>
      <td class="num">63</td>
      <td class="num">64</td>
      <td class="outer"><span class="pill c-multi">IO N MV</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-multi">IO P MV</span></td>
      <td class="num">65</td>
      <td class="num">66</td>
      <td class="outer"><span class="pill c-multi">IO P MV</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
      <td class="num">67</td>
      <td class="num">68</td>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
    </tr>    <tr>
      <td class="outer"><span class="pill c-multi">IO N MV</span></td>
      <td class="num">69</td>
      <td class="num">70</td>
      <td class="outer"><span class="pill c-multi">IO N MV</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-multi">IO P MV</span></td>
      <td class="num">71</td>
      <td class="num">72</td>
      <td class="outer"><span class="pill c-multi">IO P MV</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
      <td class="num">73</td>
      <td class="num">74</td>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
    </tr>    <tr>
      <td class="outer"><span class="pill c-multi">IO N MV</span></td>
      <td class="num">75</td>
      <td class="num">76</td>
      <td class="outer"><span class="pill c-multi">IO N MV</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-multi">IO P MV</span></td>
      <td class="num">77</td>
      <td class="num">78</td>
      <td class="outer"><span class="pill c-multi">IO P MV</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
      <td class="num">79</td>
      <td class="num">80</td>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
    </tr>
  </tbody>
</table>
</div>
<div class="pinout-table-container">
<h2>Control</h2>
<table class="pin-table" aria-label="Pin table">
  <colgroup>
    <col class="outer">
    <col class="num">
    <col class="num">
    <col class="outer">
  </colgroup>
  <tbody>
    <tr>
      <td class="outer"><span class="pill c-3v3">+3.3V</span></td>
      <td class="num">1</td>
      <td class="num">2</td>
      <td class="outer"><span class="pill c-vdd">VDD</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-3v3">+3.3V</span></td>
      <td class="num">3</td>
      <td class="num">4</td>
      <td class="outer"><span class="pill c-vdd">VDD</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-3v3">+3.3V</span></td>
      <td class="num">5</td>
      <td class="num">6</td>
      <td class="outer"><span class="pill c-vdd">VDD</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-3v3">+3.3V</span></td>
      <td class="num">7</td>
      <td class="num">8</td>
      <td class="outer"><span class="pill c-vdd">VDD</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-3v3">+3.3V</span></td>
      <td class="num">9</td>
      <td class="num">10</td>
      <td class="outer"><span class="pill c-vdd">VDD</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-3v3">+3.3V</span></td>
      <td class="num">11</td>
      <td class="num">12</td>
      <td class="outer"><span class="pill c-vdd">VDD</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-3v3">+3.3V</span></td>
      <td class="num">13</td>
      <td class="num">14</td>
      <td class="outer"><span class="pill c-vdd">VDD</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-3v3">+3.3V</span></td>
      <td class="num">15</td>
      <td class="num">16</td>
      <td class="outer"><span class="pill c-vdd">VDD</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
      <td class="num">17</td>
      <td class="num">18</td>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
      <td class="num">19</td>
      <td class="num">20</td>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
      <td class="num">21</td>
      <td class="num">22</td>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
      <td class="num">23</td>
      <td class="num">24</td>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
      <td class="num">25</td>
      <td class="num">26</td>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
      <td class="num">27</td>
      <td class="num">28</td>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-io-diff">IO N</span></td>
      <td class="num">29</td>
      <td class="num">30</td>
      <td class="outer"><span class="pill c-io-diff">IO N</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-io-diff">IO P</span></td>
      <td class="num">31</td>
      <td class="num">32</td>
      <td class="outer"><span class="pill c-io-diff">IO P</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-io-diff">IO N</span></td>
      <td class="num">33</td>
      <td class="num">34</td>
      <td class="outer"><span class="pill c-io-diff">IO N</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-io-diff">IO P</span></td>
      <td class="num">35</td>
      <td class="num">36</td>
      <td class="outer"><span class="pill c-io-diff">IO P</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-io">RESET</span></td>
      <td class="num">37</td>
      <td class="num">38</td>
      <td class="outer"><span class="pill c-multi">VBSEL A</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-config">DONE</span></td>
      <td class="num">39</td>
      <td class="num">40</td>
      <td class="outer"><span class="pill c-multi">VBSEL B</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-config">PROGRAM</span></td>
      <td class="num">41</td>
      <td class="num">42</td>
      <td class="outer"><span class="pill c-analog">A1.8V</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-config">TDI*</span></td>
      <td class="num">43</td>
      <td class="num">44</td>
      <td class="outer"><span class="pill c-analog">AV P</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-config">TDO*</span></td>
      <td class="num">45</td>
      <td class="num">46</td>
      <td class="outer"><span class="pill c-analog">AV N</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-config">TMS*</span></td>
      <td class="num">47</td>
      <td class="num">48</td>
      <td class="outer"><span class="pill c-analog">AREF</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-config">TCK*</span></td>
      <td class="num">49</td>
      <td class="num">50</td>
      <td class="outer"><span class="pill c-analog">AGND</span></td>
    </tr>
  </tbody>
</table>
<h2>VBSEL Values</h2>
<table class="mv-table">
  <thead>
    <tr>
      <th>VBSEL A</th>
      <th>VBSEL B</th>
      <th>MV VCCO</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>floating</td>
      <td>floating</td>
      <td>3.3</td>
    </tr>
    <tr>
      <td>low</td>
      <td>low</td>
      <td>3.3</td>
    </tr>
    <tr>
      <td>low</td>
      <td>high</td>
      <td>3.3</td>
    </tr>
    <tr>
      <td>high</td>
      <td>low</td>
      <td>1.8</td>
    </tr>
    <tr>
      <td>high</td>
      <td>high</td>
      <td>2.5</td>
    </tr>
    <tr>
      <td>VBSEL B</td>
      <td>VBSEL A</td>
      <td>2.5</td>
    </tr>
  </tbody>
</table>
<p>low = 0-0.9 volts<br/>
high = 1.1-3.3 volts</p>
</div>
</div>
<div class="pinout-legend">
<h2>Legend</h2>
<table class="pin-table" aria-label="Pin table">
  <colgroup>
    <col class="outer">
    <col class="num">
  </colgroup>
<tbody>
<tr>
  <td class="outer"><span class="pill c-io">IO</span></td>
  <td>Standard IO. <code>SDA</code> and <code>SCL</code> also connect to the QWIIC connector. The 1.35V pins are not 3.3V tolerant</td>
</tr>
<tr>
  <td class="outer"><span class="pill c-io-diff">IO N/P</span></td>
  <td>Differential capable IO</td>
</tr>
<tr>
  <td class="outer"><span class="pill c-clock">MRCC/SRCC</span></td>
  <td>Clock capable input. Single ended clocks must go to the <code>P</code> pin of the pair</td>
</tr>
<tr>
  <td class="outer"><span class="pill c-multi">Multi-voltage</span></td>
  <td>Multi-voltage pin. The VCCO for these pins is controllable via <code>VBSEL A</code> and <code>VBSEL B</code></td>
</tr>
<tr>
  <td class="outer"><span class="pill c-analog">Analog</span></td>
  <td>Analog signal. <code>IO N/P A</code> and <code>AV P/N</code> are 1V inputs</td>
</tr>
<tr>
  <td class="outer"><span class="pill c-config">CONFIG</span></td>
  <td>Configuration signal</td>
</tr>
<tr>
  <td class="outer"><span class="pill c-3v3">+3.3V</span></td>
  <td>3.3V output</td>
</tr>
<tr>
  <td class="outer"><span class="pill c-vdd">VDD</span></td>
  <td>5V-12V board power. When plugged into USB, this can supply 5V. The USB port is protected against higher voltages</td>
</tr>
<tr>
  <td class="outer"><span class="pill c-gnd">GND</span></td>
  <td>Ground</td>
</tr>
</tbody>
</table>
<p>* JTAG pins will be reordered to match the Au on rev B</p>
</div>
</details>
<details class="pinout-details">
<summary>Bottom Pinout Table</summary>
<div class="pinout-table-group">
<div class="callout-box callout-warning">
    <div class="callout-icon"></div>
    <div class="callout-content">
        <p>The bottom side pin numbers are bank numbers, and the corresponding connector pin number is mirrored (pin 1 is pin 2 and pin 2 is 1)</p>
    </div>
</div>
<div class="pinout-table-container">
<h2>Bank A</h2>
<table class="pin-table" aria-label="Pin table">
  <colgroup>
    <col class="outer">
    <col class="num">
    <col class="num">
    <col class="outer">
  </colgroup>
  <tbody>
    <tr>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
      <td class="num">1</td>
      <td class="num">2</td>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-io-diff">IO N</span></td>
      <td class="num">3</td>
      <td class="num">4</td>
      <td class="outer"><span class="pill c-io-diff">IO N</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-io-diff">IO P</span></td>
      <td class="num">5</td>
      <td class="num">6</td>
      <td class="outer"><span class="pill c-io-diff">IO P</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
      <td class="num">7</td>
      <td class="num">8</td>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-io-diff">IO N</span></td>
      <td class="num">9</td>
      <td class="num">10</td>
      <td class="outer"><span class="pill c-io-diff">IO N</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-io-diff">IO P</span></td>
      <td class="num">11</td>
      <td class="num">12</td>
      <td class="outer"><span class="pill c-io-diff">IO P</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
      <td class="num">13</td>
      <td class="num">14</td>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-io-diff">IO N</span></td>
      <td class="num">15</td>
      <td class="num">16</td>
      <td class="outer"><span class="pill c-io-diff">IO N</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-io-diff">IO P</span></td>
      <td class="num">17</td>
      <td class="num">18</td>
      <td class="outer"><span class="pill c-io-diff">IO P</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
      <td class="num">19</td>
      <td class="num">20</td>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-io-diff">IO N</span></td>
      <td class="num">21</td>
      <td class="num">22</td>
      <td class="outer"><span class="pill c-io-diff">IO N</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-io-diff">IO P</span></td>
      <td class="num">23</td>
      <td class="num">24</td>
      <td class="outer"><span class="pill c-io-diff">IO P</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
      <td class="num">25</td>
      <td class="num">26</td>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-io-diff">IO N</span></td>
      <td class="num">27</td>
      <td class="num">28</td>
      <td class="outer"><span class="pill c-io-diff">IO N</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-io-diff">IO P</span></td>
      <td class="num">29</td>
      <td class="num">30</td>
      <td class="outer"><span class="pill c-io-diff">IO P</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
      <td class="num">31</td>
      <td class="num">32</td>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-io-diff">IO N</span></td>
      <td class="num">33</td>
      <td class="num">34</td>
      <td class="outer"><span class="pill c-io-diff">IO N</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-io-diff">IO P</span></td>
      <td class="num">35</td>
      <td class="num">36</td>
      <td class="outer"><span class="pill c-io-diff">IO P</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
      <td class="num">37</td>
      <td class="num">38</td>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
    </tr>
        <tr>
      <td class="outer"><span class="pill c-clock">IO N - MRCC</span></td>
      <td class="num">39</td>
      <td class="num">40</td>
      <td class="outer"><span class="pill c-clock">IO N - SRCC</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-clock">IO P - MRCC</span></td>
      <td class="num">41</td>
      <td class="num">42</td>
      <td class="outer"><span class="pill c-clock">IO P - SRCC</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
      <td class="num">43</td>
      <td class="num">44</td>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-clock">IO N - MRCC</span></td>
      <td class="num">45</td>
      <td class="num">46</td>
      <td class="outer"><span class="pill c-clock">IO N - SRCC</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-clock">IO P - MRCC</span></td>
      <td class="num">47</td>
      <td class="num">48</td>
      <td class="outer"><span class="pill c-clock">IO P - SRCC</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
      <td class="num">49</td>
      <td class="num">50</td>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-io-diff">IO N</span></td>
      <td class="num">51</td>
      <td class="num">52</td>
      <td class="outer"><span class="pill c-io-diff">IO N</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-io-diff">IO P</span></td>
      <td class="num">53</td>
      <td class="num">54</td>
      <td class="outer"><span class="pill c-io-diff">IO P</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
      <td class="num">55</td>
      <td class="num">56</td>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-io-diff">IO N</span></td>
      <td class="num">57</td>
      <td class="num">58</td>
      <td class="outer"><span class="pill c-io-diff">IO N</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-io-diff">IO P</span></td>
      <td class="num">59</td>
      <td class="num">60</td>
      <td class="outer"><span class="pill c-io-diff">IO P</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
      <td class="num">61</td>
      <td class="num">62</td>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-io-diff">IO N</span></td>
      <td class="num">63</td>
      <td class="num">64</td>
      <td class="outer"><span class="pill c-io-diff">IO N</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-io-diff">IO P</span></td>
      <td class="num">65</td>
      <td class="num">66</td>
      <td class="outer"><span class="pill c-io-diff">IO P</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
      <td class="num">67</td>
      <td class="num">68</td>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
    </tr>    <tr>
      <td class="outer"><span class="pill c-io-diff">IO N</span></td>
      <td class="num">69</td>
      <td class="num">70</td>
      <td class="outer"><span class="pill c-io-diff">IO N</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-io-diff">IO P</span></td>
      <td class="num">71</td>
      <td class="num">72</td>
      <td class="outer"><span class="pill c-io-diff">IO P</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
      <td class="num">73</td>
      <td class="num">74</td>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
    </tr>    
    <tr>
      <td class="outer"><span class="pill c-io-diff">IO N</span></td>
      <td class="num">75</td>
      <td class="num">76</td>
      <td class="outer"><span class="pill c-io-diff">IO N</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-io-diff">IO P</span></td>
      <td class="num">77</td>
      <td class="num">78</td>
      <td class="outer"><span class="pill c-io-diff">IO P</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
      <td class="num">79</td>
      <td class="num">80</td>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
    </tr>
  </tbody>
</table>
</div>
<div class="pinout-table-container">
<h2>Bank B</h2>
<table class="pin-table" aria-label="Pin table">
  <colgroup>
    <col class="outer">
    <col class="num">
    <col class="num">
    <col class="outer">
  </colgroup>
  <tbody>
    <tr>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
      <td class="num">1</td>
      <td class="num">2</td>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-io-diff">IO N</span></td>
      <td class="num">3</td>
      <td class="num">4</td>
      <td class="outer"><span class="pill c-io-diff">IO N</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-io-diff">IO P</span></td>
      <td class="num">5</td>
      <td class="num">6</td>
      <td class="outer"><span class="pill c-io-diff">IO P</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
      <td class="num">7</td>
      <td class="num">8</td>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-io-diff">IO N</span></td>
      <td class="num">9</td>
      <td class="num">10</td>
      <td class="outer"><span class="pill c-io-diff">IO N</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-io-diff">IO P</span></td>
      <td class="num">11</td>
      <td class="num">12</td>
      <td class="outer"><span class="pill c-io-diff">IO P</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
      <td class="num">13</td>
      <td class="num">14</td>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-io-diff">IO N</span></td>
      <td class="num">15</td>
      <td class="num">16</td>
      <td class="outer"><span class="pill c-io-diff">IO N</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-io-diff">IO P</span></td>
      <td class="num">17</td>
      <td class="num">18</td>
      <td class="outer"><span class="pill c-io-diff">IO P</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
      <td class="num">19</td>
      <td class="num">20</td>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-io-diff">IO N</span></td>
      <td class="num">21</td>
      <td class="num">22</td>
      <td class="outer"><span class="pill c-io-diff">IO N</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-io-diff">IO P</span></td>
      <td class="num">23</td>
      <td class="num">24</td>
      <td class="outer"><span class="pill c-io-diff">IO P</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
      <td class="num">25</td>
      <td class="num">26</td>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-io-diff">IO N</span></td>
      <td class="num">27</td>
      <td class="num">28</td>
      <td class="outer"><span class="pill c-io-diff">IO N</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-io-diff">IO P</span></td>
      <td class="num">29</td>
      <td class="num">30</td>
      <td class="outer"><span class="pill c-io-diff">IO P</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
      <td class="num">31</td>
      <td class="num">32</td>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-io-diff">IO N</span></td>
      <td class="num">33</td>
      <td class="num">34</td>
      <td class="outer"><span class="pill c-io-diff">IO N</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-io-diff">IO P</span></td>
      <td class="num">35</td>
      <td class="num">36</td>
      <td class="outer"><span class="pill c-io-diff">IO P</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
      <td class="num">37</td>
      <td class="num">38</td>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
    </tr>
        <tr>
      <td class="outer"><span class="pill c-clock">IO N - MRCC</span></td>
      <td class="num">39</td>
      <td class="num">40</td>
      <td class="outer"><span class="pill c-clock">IO N - SRCC</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-clock">IO P - MRCC</span></td>
      <td class="num">41</td>
      <td class="num">42</td>
      <td class="outer"><span class="pill c-clock">IO P - SRCC</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
      <td class="num">43</td>
      <td class="num">44</td>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-clock">IO N - MRCC</span></td>
      <td class="num">45</td>
      <td class="num">46</td>
      <td class="outer"><span class="pill c-clock">IO N - SRCC</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-clock">IO P - MRCC</span></td>
      <td class="num">47</td>
      <td class="num">48</td>
      <td class="outer"><span class="pill c-clock">IO P - SRCC</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
      <td class="num">49</td>
      <td class="num">50</td>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-mgt">MGT CLK0 N</span></td>
      <td class="num">51</td>
      <td class="num">52</td>
      <td class="outer"><span class="pill c-mgt">MGT CLK1 N</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-mgt">MGT CLK0 P</span></td>
      <td class="num">53</td>
      <td class="num">54</td>
      <td class="outer"><span class="pill c-mgt">MGT CLK0 N</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
      <td class="num">55</td>
      <td class="num">56</td>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-mgt">MGT TX0 N</span></td>
      <td class="num">57</td>
      <td class="num">58</td>
      <td class="outer"><span class="pill c-mgt">MGT RX0 N</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-mgt">MGT TX0 P</span></td>
      <td class="num">59</td>
      <td class="num">60</td>
      <td class="outer"><span class="pill c-mgt">MGT RX0 P</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
      <td class="num">61</td>
      <td class="num">62</td>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-mgt">MGT TX1 N</span></td>
      <td class="num">63</td>
      <td class="num">64</td>
      <td class="outer"><span class="pill c-mgt">MGT RX1 N</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-mgt">MGT TX1 P</span></td>
      <td class="num">65</td>
      <td class="num">66</td>
      <td class="outer"><span class="pill c-mgt">MGT RX1 P</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
      <td class="num">67</td>
      <td class="num">68</td>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
    </tr>    <tr>
      <td class="outer"><span class="pill c-mgt">MGT TX2 N</span></td>
      <td class="num">69</td>
      <td class="num">70</td>
      <td class="outer"><span class="pill c-mgt">MGT RX2 N</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-mgt">MGT TX2 P</span></td>
      <td class="num">71</td>
      <td class="num">72</td>
      <td class="outer"><span class="pill c-mgt">MGT RX2 P</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
      <td class="num">73</td>
      <td class="num">74</td>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
    </tr>    
    <tr>
      <td class="outer"><span class="pill c-mgt">MGT TX3 N</span></td>
      <td class="num">75</td>
      <td class="num">76</td>
      <td class="outer"><span class="pill c-mgt">MGT RX3 N</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-mgt">MGT TX3 P</span></td>
      <td class="num">77</td>
      <td class="num">78</td>
      <td class="outer"><span class="pill c-mgt">MGT RX3 P</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
      <td class="num">79</td>
      <td class="num">80</td>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
    </tr>
  </tbody>
</table>
</div>
<div class="pinout-table-container">
<h2>Control</h2>
<table class="pin-table" aria-label="Pin table">
  <colgroup>
    <col class="outer">
    <col class="num">
    <col class="num">
    <col class="outer">
  </colgroup>
  <tbody>
    <tr>
      <td class="outer"><span class="pill c-3v3">+3.3V</span></td>
      <td class="num">1</td>
      <td class="num">2</td>
      <td class="outer"><span class="pill c-vdd">VDD</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-3v3">+3.3V</span></td>
      <td class="num">3</td>
      <td class="num">4</td>
      <td class="outer"><span class="pill c-vdd">VDD</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-3v3">+3.3V</span></td>
      <td class="num">5</td>
      <td class="num">6</td>
      <td class="outer"><span class="pill c-vdd">VDD</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-3v3">+3.3V</span></td>
      <td class="num">7</td>
      <td class="num">8</td>
      <td class="outer"><span class="pill c-vdd">VDD</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-3v3">+3.3V</span></td>
      <td class="num">9</td>
      <td class="num">10</td>
      <td class="outer"><span class="pill c-vdd">VDD</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-3v3">+3.3V</span></td>
      <td class="num">11</td>
      <td class="num">12</td>
      <td class="outer"><span class="pill c-vdd">VDD</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-3v3">+3.3V</span></td>
      <td class="num">13</td>
      <td class="num">14</td>
      <td class="outer"><span class="pill c-vdd">VDD</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-3v3">+3.3V</span></td>
      <td class="num">15</td>
      <td class="num">16</td>
      <td class="outer"><span class="pill c-vdd">VDD</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
      <td class="num">17</td>
      <td class="num">18</td>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
      <td class="num">19</td>
      <td class="num">20</td>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
      <td class="num">21</td>
      <td class="num">22</td>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
      <td class="num">23</td>
      <td class="num">24</td>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
      <td class="num">25</td>
      <td class="num">26</td>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
      <td class="num">27</td>
      <td class="num">28</td>
      <td class="outer"><span class="pill c-gnd">GND</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-io-diff">IO N</span></td>
      <td class="num">29</td>
      <td class="num">30</td>
      <td class="outer"><span class="pill c-io-diff">IO N</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-io-diff">IO P</span></td>
      <td class="num">31</td>
      <td class="num">32</td>
      <td class="outer"><span class="pill c-io-diff">IO P</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-io-diff">IO N</span></td>
      <td class="num">33</td>
      <td class="num">34</td>
      <td class="outer"><span class="pill c-io-diff">IO N</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-io-diff">IO P</span></td>
      <td class="num">35</td>
      <td class="num">36</td>
      <td class="outer"><span class="pill c-io-diff">IO P</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-io">RESET</span></td>
      <td class="num">37</td>
      <td class="num">38</td>
      <td class="outer"><span class="pill c-multi">VBSEL A</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-config">DONE</span></td>
      <td class="num">39</td>
      <td class="num">40</td>
      <td class="outer"><span class="pill c-multi">VBSEL B</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-config">PROGRAM</span></td>
      <td class="num">41</td>
      <td class="num">42</td>
      <td class="outer"><span class="pill c-analog">A1.8V</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-config">TDI*</span></td>
      <td class="num">43</td>
      <td class="num">44</td>
      <td class="outer"><span class="pill c-analog">AV P</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-config">TDO*</span></td>
      <td class="num">45</td>
      <td class="num">46</td>
      <td class="outer"><span class="pill c-analog">AV N</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-config">TMS*</span></td>
      <td class="num">47</td>
      <td class="num">48</td>
      <td class="outer"><span class="pill c-analog">AREF</span></td>
    </tr>
    <tr>
      <td class="outer"><span class="pill c-config">TCK*</span></td>
      <td class="num">49</td>
      <td class="num">50</td>
      <td class="outer"><span class="pill c-analog">AGND</span></td>
    </tr>
  </tbody>
</table>
<h2>VBSEL Values</h2>
<table class="mv-table">
  <thead>
    <tr>
      <th>VBSEL A</th>
      <th>VBSEL B</th>
      <th>MV VCCO</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>floating</td>
      <td>floating</td>
      <td>3.3</td>
    </tr>
    <tr>
      <td>low</td>
      <td>low</td>
      <td>3.3</td>
    </tr>
    <tr>
      <td>low</td>
      <td>high</td>
      <td>3.3</td>
    </tr>
    <tr>
      <td>high</td>
      <td>low</td>
      <td>1.8</td>
    </tr>
    <tr>
      <td>high</td>
      <td>high</td>
      <td>2.5</td>
    </tr>
    <tr>
      <td>VBSEL B</td>
      <td>VBSEL A</td>
      <td>2.5</td>
    </tr>
  </tbody>
</table>
<p>low = 0-0.9 volts<br/>
high = 1.1-3.3 volts</p>
</div>
</div>
<div class="pinout-legend">
<h2>Legend</h2>
<table class="pin-table" aria-label="Pin table">
  <colgroup>
    <col class="outer">
    <col class="num">
  </colgroup>
<tbody>
<tr>
  <td class="outer"><span class="pill c-io">IO</span></td>
  <td>Standard IO. <code>SDA</code> and <code>SCL</code> also connect to the QWIIC connector. The 1.35V pins are not 3.3V tolerant</td>
</tr>
<tr>
  <td class="outer"><span class="pill c-io-diff">IO N/P</span></td>
  <td>Differential capable IO</td>
</tr>
<tr>
  <td class="outer"><span class="pill c-clock">MRCC/SRCC</span></td>
  <td>Clock capable input. Single ended clocks must go to the <code>P</code> pin of the pair</td>
</tr>
<tr>
  <td class="outer"><span class="pill c-mgt">MGT</span></td>
  <td>Multi-Gigabit Transceiver</td>
</tr>
<tr>
  <td class="outer"><span class="pill c-multi">Multi-voltage</span></td>
  <td>Multi-voltage pin. The VCCO for these pins is controllable via <code>VBSEL A</code> and <code>VBSEL B</code></td>
</tr>
<tr>
  <td class="outer"><span class="pill c-analog">Analog</span></td>
  <td>Analog signal. <code>IO N/P A</code> and <code>AV P/N</code> are 1V inputs</td>
</tr>
<tr>
  <td class="outer"><span class="pill c-config">CONFIG</span></td>
  <td>Configuration signal</td>
</tr>
<tr>
  <td class="outer"><span class="pill c-3v3">+3.3V</span></td>
  <td>3.3V output</td>
</tr>
<tr>
  <td class="outer"><span class="pill c-vdd">VDD</span></td>
  <td>5V-12V board power. When plugged into USB, this can supply 5V. The USB port is protected against higher voltages</td>
</tr>
<tr>
  <td class="outer"><span class="pill c-gnd">GND</span></td>
  <td>Ground</td>
</tr>
</tbody>
</table>
<p>* JTAG pins will be reordered to match the Au on rev B</p>
</div>
</details>

# PCB Layout

## Alchitry V2 Element Libraries

These are libraries that already have the connectors in the right place and the pins labeled with the signal names.

* [KiCad](https://cdn.alchitry.com/elements/Alchitry%20V2%20Elements%20KiCAD.zip)
* [Altium Develop](https://cdn.alchitry.com/elements/Alchitry%20V2%20Elements.IntLib)
* [Fusion](https://cdn.alchitry.com/elements/Alchitry%20V2%20Elements.flbr)
* [Eagle 9.x](https://cdn.alchitry.com/elements/Alchitry%20V2%20Elements.lbr)