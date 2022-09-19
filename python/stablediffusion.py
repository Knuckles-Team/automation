#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from transformers import AutoTokenizer, GPTJForCausalLM, pipeline, AutoModelForCausalLM
import torch
import psutil
import os
import re

tokenizer = AutoTokenizer.from_pretrained("CompVis/stable-diffusion-v-1-4-original")
model = AutoModel.from_pretrained("CompVis/stable-diffusion-v-1-4-original")
